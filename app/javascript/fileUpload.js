
import {
  Core,
  Dashboard,
  AwsS3,
} from 'uppy';
import { Plugin } from '@uppy/core';

import randomstring from 'randomstring';
import { t } from './i18n';

/* Mecha plugin */
class MechaValidator extends Plugin {
  constructor (uppy, opts = {}) {
    super(uppy, opts)
    this.id = opts.id || 'MechaValidator';
    this.type = 'validator'
    this.csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    this.previewElement = opts.previewElement;
  }

  prepareUpload = (fileIDs) => {
    this.resetPreview();

    const promises = fileIDs.map(async (fileID) => {
      const file = this.uppy.getFile(fileID)
      this.uppy.emit('preprocess-progress', file, {
        mode: 'indeterminate',
        message: t('uppy.validating'),
      });

      const formData = new FormData();
      formData.append("mecha_file", file.data);

      return fetch('/blueprint/mechas/analyze', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.csrf,
        },
        body: formData,
      })
      .then((response) => response.json())
      .then(function(data) {
        if (data) {
          if (data.error) {
            throw new Error(data.error);
          }

          return data;
        }
      });
    })

    const emitPreprocessCompleteForAll = (responses) => {
      fileIDs.forEach((fileID, index) => {
        const mechaData = responses[index];
        const file = this.uppy.getFile(fileID);
        if (mechaData.valid) {
          this.displayPreview(mechaData);
          this.uppy.emit('preprocess-complete', file)
        }
      })
    }

    const handleValidationFailure = (error) => {
      console.warn('Mecha file validation failure ->', error);
      this.uppy.cancelAll();
      this.uppy.emit('cancel-all', file);
    }

    return Promise.all(promises).then(emitPreprocessCompleteForAll).catch(handleValidationFailure)
  }

  displayPreview(data) {
    this.resetPreview();

    if ('content' in document.createElement('template')) {
      const container = document.querySelector('.m-form__file-preview');
      const previewTemplate = document.querySelector('#bp-preview').content.cloneNode(true);

      previewTemplate.querySelector(".t-blueprint__mecha-preview-name").textContent = data.name;
      previewTemplate.querySelector(".t-blueprint__mecha-preview-image").setAttribute('src', `data:image/jpeg;base64,${data.preview}`)

      container.prepend(previewTemplate);
    }
  }

  resetPreview() {
    if (document.querySelector('.t-blueprint__mecha-preview')) {
      document.querySelector('.t-blueprint__mecha-preview').remove();
    }
  }

  install () {
    this.uppy.addPreProcessor(this.prepareUpload);
  }

  uninstall () {
    this.uppy.removePreProcessor(this.prepareUpload);
  }
}

const UPPY_DEFAULT_OPTIONS = {
  inline: true,
  height: 200,
  width: '100%',
  doneButtonHandler: null,
  hideProgressAfterFinish: true,
  showLinkToFileUploadResult: false,
  proudlyDisplayPoweredByUppy: false,
  showProgressDetails: true,
  replaceTargetContent: true,
  theme: 'dark',
};

const singleFileUpload = (fileInput) => {
  const data = fileInput.dataset;
  const container = fileInput.parentNode;
  const uppy = fileUpload(fileInput, { maximum: 1, maxFileSize: data.maxFileSize || null });;
  const fileSizeMB = data.maxFileSize ? data.maxFileSize / (1024 * 1024) : '3';
  const isMecha = data.mechaPlugin === 'true';

  container.removeChild(fileInput);

  // Use mecha-specific translations if this is a mecha upload
  const dropPasteText = isMecha ? t('uppy.mecha_title') : t('uppy.drop_paste');
  const noteText = isMecha ? t('uppy.mecha_description') : t('uppy.single_note').replace('%{size}', fileSizeMB);

  uppy
    .use(Dashboard, {
      ...UPPY_DEFAULT_OPTIONS,
      target: container,
      locale: {
        strings: {
          dropPaste: dropPasteText,
          browse: t('uppy.browse'),
          uploadFailed: t('uppy.mecha_error'),
        }
      },
      note: noteText,
    });

  if (data.mechaPlugin === 'true') {
    uppy.use(MechaValidator);
  }

  uppy.on('upload-success', (file, response) => {
    const fileData = uploadedFileData(file, response, fileInput);
    if (data.uploadResultElement) {
      const hiddenInput = document.getElementById(data.uploadResultElement);
      hiddenInput.value = fileData;
    }
  });

  uppy.on('complete', () => {
    createResetButton(container, uppy);
  });
}

const multipleFileUpload = (fileInput) => {
  const data = fileInput.dataset;
  const container = fileInput.parentNode
  const uppy = fileUpload(fileInput, { maximum: 4, maxFileSize: data.maxFileSize || null })
  const fileSizeMB = data.maxFileSize ? data.maxFileSize / (1024 * 1024) : '3';

  uppy
    .use(Dashboard, {
      ...UPPY_DEFAULT_OPTIONS,
      target: container,
      locale: {
        strings: {
          dropPaste: data.title || t('uppy.drop_paste'),
          browse: t('uppy.browse'),
        }
      },
      note: data.description || t('uppy.multiple_note').replace('%{max}', '4').replace('%{size}', fileSizeMB),
    })

  uppy.on('upload-success', (file, response) => {
    const hiddenField = document.createElement('input')

    hiddenField.classList = 'm-form__pictures-additional-pictures-data';
    hiddenField.type = 'hidden'
    hiddenField.name = `${data.modelName || 'blueprint'}[additional_pictures_attributes][${randomstring.generate()}][picture]`
    hiddenField.value = uploadedFileData(file, response, fileInput)

    document.querySelector('form').appendChild(hiddenField)
  });

  uppy.on('upload', () => {
    const submit = document.querySelector('form input[type=submit]');
    submit.disabled = true;
  });

  uppy.on('complete', () => {
    createResetButton(container, uppy);

    const submit = document.querySelector('form input[type=submit]');
    submit.disabled = false;
  });
}

const createResetButton = (container, uppy) => {
  if (!container.querySelector('.uppy-DashboardContent-bar .uppy-DashboardContent-reset-button')) {
    const resetButton = document.createElement('button');
    resetButton.classList = 'uppy-DashboardContent-reset-button';
    resetButton.textContent = t('uppy.reset');
    resetButton.addEventListener('click', function() {
      document
        .querySelectorAll('.m-form__pictures-additional-pictures-data')
        .forEach(element => element.remove())
      uppy.reset();
    });

    container.querySelector('.uppy-DashboardContent-bar').appendChild(resetButton);
  }
}

const fileUpload = (fileInput, { maximum, maxFileSize }) => {
  const uppy = Core({
    id: fileInput.id,
    autoProceed: true,
    restrictions: {
      maxFileSize: maxFileSize || 3*1024*1024,
      maxNumberOfFiles: maximum,
      allowedFileTypes: fileInput.accept.split(','),
    },
  });

  uppy.use(AwsS3, {
    companionUrl: '/', // will call Shrine's presign endpoint mounted on `/s3/params`
  });

  return uppy;
}

const uploadedFileData = (file, response, fileInput) => {
  const id = file.meta['key'].match(/^cache\/(.+)/)[1]; // object key without prefix

  return JSON.stringify(fileData(file, id))
}

// Constructs uploaded file data in the format that Shrine expects
const fileData = (file, id) => ({
  id: id,
  storage: 'cache',
  metadata: {
    size:      file.size,
    filename:  file.name,
    mime_type: file.type,
  }
})

export { singleFileUpload, multipleFileUpload }