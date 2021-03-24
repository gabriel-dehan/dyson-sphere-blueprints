
import {
  Core,
  Dashboard,
  AwsS3,
} from 'uppy'

import randomstring from 'randomstring';

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
  const container = fileInput.parentNode;
  container.removeChild(fileInput);
  const uppy = fileUpload(fileInput, { maximum: 1 });

  uppy
    .use(Dashboard, {
      ...UPPY_DEFAULT_OPTIONS,
      target: container,
      note: 'Single cover picture. 3 MB maximum, ideal ratio 16:9. For instance 1920x1080, etc...',
    });

  uppy.on('upload-success', (file, response) => {
    const fileData = uploadedFileData(file, response, fileInput);
    const hiddenInput = document.getElementById(fileInput.dataset.uploadResultElement);
    hiddenInput.value = fileData;
  });

  uppy.on('complete', () => {
    createResetButton(container, uppy);
  });
}

const multipleFileUpload = (fileInput) => {
  const container = fileInput.parentNode
  const uppy = fileUpload(fileInput, { maximum: 4 })

  uppy
    .use(Dashboard, {
      ...UPPY_DEFAULT_OPTIONS,
      target: container,
      note: '4 pictures maximum, 3 MB maximum each, ideal ratio 16:9. For instance 1920x1080, etc...',
    })

  uppy.on('upload-success', (file, response) => {
    const hiddenField = document.createElement('input')

    hiddenField.classList = 'm-form__pictures-additional-pictures-data';
    hiddenField.type = 'hidden'
    hiddenField.name = `blueprint[additional_pictures_attributes][${randomstring.generate()}][picture]`
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
    resetButton.textContent = 'Reset';
    resetButton.addEventListener('click', function() {
      document
        .querySelectorAll('.m-form__pictures-additional-pictures-data')
        .forEach(element => element.remove())
      uppy.reset();
    });

    container.querySelector('.uppy-DashboardContent-bar').appendChild(resetButton);
  }
}

const fileUpload = (fileInput, { maximum }) => {
  const uppy = Core({
    id: fileInput.id,
    autoProceed: true,
    restrictions: {
      maxFileSize: 3*1024*1024,
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