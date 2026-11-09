import * as pako from 'pako';

const BELT_IDS = [2001, 2002, 2003];
const INSERTER_IDS = [2011, 2012, 2013, 2014];

class BinaryReader {
  constructor(bytes) {
    this.view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    this.offset = 0;
  }

  int8() {
    this.ensureAvailable(1);
    const value = this.view.getInt8(this.offset);
    this.offset += 1;
    return value;
  }

  uint8() {
    this.ensureAvailable(1);
    const value = this.view.getUint8(this.offset);
    this.offset += 1;
    return value;
  }

  int16() {
    this.ensureAvailable(2);
    const value = this.view.getInt16(this.offset, true);
    this.offset += 2;
    return value;
  }

  int32() {
    this.ensureAvailable(4);
    const value = this.view.getInt32(this.offset, true);
    this.offset += 4;
    return value;
  }

  float32() {
    this.ensureAvailable(4);
    const value = this.view.getFloat32(this.offset, true);
    this.offset += 4;
    return value;
  }

  skip(byteCount) {
    this.ensureAvailable(byteCount);
    this.offset += byteCount;
  }

  skipDotNetString() {
    let byteLength = 0;
    let shift = 0;

    while (shift < 35) {
      const byte = this.uint8();
      byteLength |= (byte & 0x7f) << shift;

      if ((byte & 0x80) === 0) {
        this.skip(byteLength);
        return;
      }

      shift += 7;
    }

    throw new Error('Invalid blueprint string length');
  }

  ensureAvailable(byteCount) {
    if (byteCount < 0 || this.offset + byteCount > this.view.byteLength) {
      throw new Error('Unexpected end of blueprint data');
    }
  }
}

function decodeBase64(value) {
  const decoded = atob(value);
  const bytes = new Uint8Array(decoded.length);

  for (let index = 0; index < decoded.length; index += 1) {
    bytes[index] = decoded.charCodeAt(index);
  }

  return bytes;
}

function decodeHeaderValue(value) {
  return value ? decodeURIComponent(value) : '';
}

function parseHeader(rawHeader) {
  const segments = rawHeader.split(',');
  const versionMatch = segments[0].match(/^BLUEPRINT:(\d+)$/);

  if (!versionMatch) {
    throw new Error('Incorrect blueprint format');
  }

  const version = Number(versionMatch[1]);

  return {
    version,
    gameVersion: segments[9],
    shortDesc: decodeHeaderValue(segments[10]),
    desc: decodeHeaderValue(version >= 1 ? segments[14] : segments[11])
  };
}

function parseParameters(reader) {
  const parameterCount = reader.int16();

  if (parameterCount < 0) {
    throw new Error('Invalid blueprint parameter count');
  }

  const parameters = [];

  for (let index = 0; index < parameterCount; index += 1) {
    parameters.push(reader.int32());
  }

  return parameters;
}

function parseBuildingTail(reader, building) {
  reader.int32(); // Output building index
  reader.int32(); // Input building index
  reader.skip(6); // Input/output slots and offsets

  building.recipeId = reader.int16();
  building.filterId = reader.int16();
  building.parameters = parseParameters(reader);

  return building;
}

function parseModernBuilding(reader, hasContent) {
  const building = {
    index: reader.int32(),
    itemId: reader.int16(),
    modelIndex: reader.int16(),
    areaIndex: reader.int8()
  };

  reader.float32(); // Local X
  reader.float32(); // Local Y
  reader.float32(); // Local Z
  reader.float32(); // Yaw

  if (building.itemId > 2000 && building.itemId < 2010) {
    reader.float32(); // Tilt
  } else if (building.itemId > 2010 && building.itemId < 2020) {
    // Sorters store tilt, pitch, a second position, and a second rotation.
    reader.skip(8 * 4);
  }

  parseBuildingTail(reader, building);

  if (hasContent) {
    // Version -102 added a content marker after every building. The marker
    // must be consumed even when no string follows or the next record shifts.
    const contentLength = reader.int32();
    if (contentLength > 0) {
      reader.skipDotNetString();
    }
  }

  return building;
}

function parseVersion100Building(reader) {
  const building = {
    index: reader.int32(),
    areaIndex: reader.int8()
  };

  reader.skip(6 * 4); // Two local positions
  reader.skip(2 * 4); // Two yaw values
  reader.float32(); // Tilt

  building.itemId = reader.int16();
  building.modelIndex = reader.int16();

  return parseBuildingTail(reader, building);
}

function parseLegacyBuilding(reader, index) {
  const building = {
    index,
    areaIndex: reader.int8()
  };

  reader.skip(6 * 4); // Two local positions
  reader.skip(2 * 4); // Two yaw values

  building.itemId = reader.int16();
  building.modelIndex = reader.int16();

  return parseBuildingTail(reader, building);
}

function parseBuilding(reader) {
  const recordVersion = reader.int32();

  if (recordVersion <= -102) {
    return parseModernBuilding(reader, true);
  }

  if (recordVersion <= -101) {
    return parseModernBuilding(reader, false);
  }

  if (recordVersion <= -100) {
    return parseVersion100Building(reader);
  }

  return parseLegacyBuilding(reader, recordVersion);
}

function parseContent(encodedContent) {
  const compressed = decodeBase64(encodedContent);
  const reader = new BinaryReader(pako.inflate(compressed));

  const content = {
    version: reader.int32(),
    cursorOffsetX: reader.int32(),
    cursorOffsetY: reader.int32(),
    cursorTargetArea: reader.int32(),
    dragBoxSizeX: reader.int32(),
    dragBoxSizeY: reader.int32(),
    primaryAreaIdx: reader.int32(),
    buildings: []
  };

  const areaCount = reader.uint8();
  reader.skip(areaCount * 14);

  const buildingCount = reader.int32();

  if (buildingCount < 0) {
    throw new Error('Invalid blueprint building count');
  }

  for (let index = 0; index < buildingCount; index += 1) {
    content.buildings.push(parseBuilding(reader));
  }

  return content;
}

function stationParameters(itemId, parameters) {
  const itemCount = itemId === 2103 ? 3 : 5;
  const itemSettings = [];

  for (let index = 0; index < itemCount; index += 1) {
    const baseIndex = index * 6;
    itemSettings.push({
      itemId: parameters[baseIndex],
      localLogic: parameters[baseIndex + 1],
      remoteLogic: parameters[baseIndex + 2],
      max: parameters[baseIndex + 3]
    });
  }

  return { itemCount, itemSettings };
}

function summarizedParameters(itemId, parameters) {
  if (itemId === 2103 || itemId === 2104) {
    return stationParameters(itemId, parameters);
  }

  return {};
}

function incrementCount(counts, itemId) {
  counts[itemId] = (counts[itemId] || 0) + 1;
}

function summarize(header, content) {
  const summary = {
    gameVersion: header.gameVersion,
    shortDesc: header.shortDesc,
    desc: header.desc,
    totalStructure: content.buildings.length,
    buildings: {},
    belts: { 2001: 0, 2002: 0, 2003: 0 },
    inserters: { 2011: 0, 2012: 0, 2013: 0, 2014: 0 }
  };

  content.buildings.forEach(building => {
    if (BELT_IDS.includes(building.itemId)) {
      incrementCount(summary.belts, building.itemId);
      return;
    }

    if (INSERTER_IDS.includes(building.itemId)) {
      incrementCount(summary.inserters, building.itemId);
      return;
    }

    if (!summary.buildings[building.itemId]) {
      summary.buildings[building.itemId] = {
        count: 0,
        recipeIds: {},
        filterIds: {},
        parameters: []
      };
    }

    const buildingSummary = summary.buildings[building.itemId];
    buildingSummary.count += 1;

    if (building.recipeId !== 0) {
      incrementCount(buildingSummary.recipeIds, building.recipeId);
    }

    if (building.filterId !== 0) {
      incrementCount(buildingSummary.filterIds, building.filterId);
    }

    if (building.parameters.length > 0) {
      buildingSummary.parameters.push(
        summarizedParameters(building.itemId, building.parameters)
      );
    }
  });

  return summary;
}

export default class DspBlueprintParser {
  constructor(rawBlueprint) {
    const blueprint = rawBlueprint.trim();
    const sections = blueprint.split('"');

    if (sections.length < 3) {
      throw new Error('Incorrect blueprint format');
    }

    this.raw = blueprint;
    this.header = parseHeader(sections[0]);
    this.content = parseContent(sections[1]);
    this.summary = summarize(this.header, this.content);
  }
}
