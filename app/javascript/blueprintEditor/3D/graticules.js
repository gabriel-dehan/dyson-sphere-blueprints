import * as THREE from "three/build/three.module";

const grid = [
  {
    segments: 20,
    count: 5,
  },
  {
    segments: 40,
    count: 5,
  },
  {
    segments: 80,
    count: 5,
  },
  {
    segments: 100,
    count: 5,
  },
  {
    segments: 160,
    count: 10,
  },
  {
    segments: 200,
    count: 10,
  },
  {
    segments: 300,
    count: 15,
  },
  {
    segments: 400,
    count: 15,
  },
  {
    segments: 500,
    count: 25,
  },
  {
    segments: 600,
    count: 25,
  },
  {
    segments: 800,
    count: 50,
  },
  {
    segments: 1000,
    count: 80,
  },
];

function* range(start, stop, step) {
  for (let i = 0, v = start; v < stop; v = start + ++i * step) {
    yield v;
  }
}

function meridian(x, y0, y1, dy = 0.36) {
  x = Math.round(x * 100) / 100;
  return Array.from(range(y0, y1 + 1e-6, dy), (y) => [x, y]);
}

function parallel(y, x0, x1, dx = 0.36) {
  y = Math.round(y * 100) / 100;
  return Array.from(range(x0, x1 + 1e-6, dx), (x) => [x, y]);
}

function vertex([longitude, latitude], radius) {
  const lambda = (longitude * Math.PI) / 180;
  const phi = (latitude * Math.PI) / 180;
  return new THREE.Vector3(
    radius * Math.cos(phi) * Math.cos(lambda),
    radius * Math.sin(phi),
    -radius * Math.cos(phi) * Math.sin(lambda)
  );
}

export const generateGraticules = function() {
  var coords = [];
  var intermediateCoords = [];
  var mainCoords = [];
  for (var i = 0; i < 1000; i++) {
    var segment = parallel(i * 0.36 - 180, -180, 180);
    if (i % 10 === 0) {
      mainCoords.push(segment);
    } else if (i % 5 === 0) {
      intermediateCoords.push(segment);
    } else {
      coords.push(segment);
    }
  }
  var index = 0;
  grid.forEach((section) => {
    var angle = 360 / section.segments;
    var start = index * 0.36;
    var end = (index + section.count) * 0.36;

    for (var i = 0; i < section.segments; i++) {
      var segA = meridian(i * angle - 180, -90 + start, -90 + end);
      var segB = meridian(i * angle - 180, 90 - end, 90 - start);
      if (i % 10 === 0) {
        mainCoords.push(segA);
        mainCoords.push(segB);
      } else if (i % 5 === 0) {
        intermediateCoords.push(segA);
        intermediateCoords.push(segB);
      } else {
        coords.push(segA);
        coords.push(segB);
      }
    }

    index += section.count;
  });

  var normal = {
    type: 'MultiLineString',
    coordinates: coords,
  };

  var intermediate = {
    type: 'MultiLineString',
    coordinates: intermediateCoords,
  };

  var main = {
    type: 'MultiLineString',
    coordinates: mainCoords,
  };
  return {
    normal,
    intermediate,
    main,
  };
}

export const wireframe = function(multilinestring, radius, material) {
  const geometry = new THREE.Geometry();
  for (const P of multilinestring.coordinates) {
    for (let p0, p1 = vertex(P[0], radius), i = 1; i < P.length; ++i) {
      geometry.vertices.push((p0 = p1), (p1 = vertex(P[i], radius)));
    }
  }
  return new THREE.LineSegments(geometry, material);
}
