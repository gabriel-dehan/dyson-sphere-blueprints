import * as THREE from "three/build/three.module";
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { MeshLine, MeshLineMaterial } from 'three.meshline';
import pako from 'pako';
import modelsData from './modelsData';

export default class {
  constructor({ tooltipContainer, container, data, width, height }) {
    this.tooltipContainer = tooltipContainer;
    this.container = container;
    this.data = JSON.parse(pako.inflate(atob(data), { to: 'string' }));
    this.rendererWidth = width;
    this.rendererHeight = height;
  }

  render() {
    var camera,
      scene,
      renderer,
      geometry,
      material,
      mesh,
      controls,
      globe,
      buildings = [],
      buildingsGroup,
      beltsGroup;

    var { data, tooltipContainer, container, rendererWidth, rendererHeight } = this;

    const DEGREES_TO_RADIANS = Math.PI / 180;
    // TODO: Change bp. to this.data.
    const bp = data;

    function* range(start, stop, step) {
      for (let i = 0, v = start; v < stop; v = start + ++i * step) {
        yield v;
      }
    }

    function meridian(x, y0, y1, dy = 1.8) {
      return Array.from(range(y0, y1 + 1e-6, dy), (y) => [x, y]);
    }

    function parallel(y, x0, x1, dx = 1.8) {
      return Array.from(range(x0, x1 + 1e-6, dx), (x) => [x, y]);
    }

    function generateGraticules() {
      var grid = [{
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

      var coords = [];
      var mainCoords = [];
      for (var i = 0; i < 1000; i++) {
        var segment = parallel(i * 0.36 - 180, -180, 180);

        if (i % 5 === 0) {
          mainCoords.push(segment);
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

          if (i % 5 === 0) {
            mainCoords.push(segA);
            mainCoords.push(segB);
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

      var main = {
        type: 'MultiLineString',
        coordinates: mainCoords,
      };
      return {
        normal,
        main,
      };
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

    function wireframe(multilinestring, radius, material) {
      const geometry = new THREE.Geometry();
      for (const P of multilinestring.coordinates) {
        for (let p0, p1 = vertex(P[0], radius), i = 1; i < P.length; ++i) {
          geometry.vertices.push((p0 = p1), (p1 = vertex(P[i], radius)));
        }
      }
      return new THREE.LineSegments(geometry, material);
    }

    function init() {
      scene = new THREE.Scene();
      camera = new THREE.PerspectiveCamera(
        50,
        rendererWidth / rendererHeight,
        1,
        10000
      );
      camera.position.z = 500;
      scene.add(camera);

      geometry = new THREE.SphereGeometry(200, 36, 36);

      globe = new THREE.Group();

      const lineMaterial = new THREE.LineBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.1,
        linewidth: 0.5,
      });
      const mainLineMaterial = new THREE.LineBasicMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.2,
      });
      const meshMaterial = new THREE.MeshPhongMaterial({
        color: 0x156289,
        emissive: 0x072534,
        side: THREE.DoubleSide,
      });

      var graticules = generateGraticules();

      var normalWf = wireframe(graticules.normal, 200, lineMaterial);
      var mainWf = wireframe(graticules.main, 200, mainLineMaterial);
      mesh = new THREE.Mesh(geometry, meshMaterial);
      globe.add(mesh);
      globe.add(mainWf);
      globe.add(normalWf);

      scene.add(globe);
      renderer = new THREE.WebGLRenderer({
        antialias: true,
      });
      renderer.setPixelRatio(window.devicePixelRatio);
      renderer.setSize(rendererWidth, rendererHeight);
      container.appendChild(renderer.domElement);

      controls = new OrbitControls(camera, renderer.domElement);
      controls.enableZoom = true;
      controls.minDistance = 250;
      controls.maxDistance = 700;

      const lights = [];
      lights[0] = new THREE.SpotLight(0xffffff, 1, 0);
      lights[1] = new THREE.SpotLight(0xffffff, 1, 0);
      lights[2] = new THREE.SpotLight(0xffffff, 1, 0);

      lights[0].position.set(0, 800, 0);
      lights[1].position.set(800, 1000, 800);
      lights[2].position.set(-800, -1000, -800);
      const ligthsGroup = new THREE.Group();
      //ligthsGroup.add(lights[0]);
      ligthsGroup.add(lights[1]);
      ligthsGroup.add(lights[2]);

      scene.add(ligthsGroup);

      const light = new THREE.AmbientLight(0x404040); // soft white light
      scene.add(light);
    }

    function LightenDarkenColor(num, amt) {
      var r = Math.min(255, Math.round((num >> 16) * (1 + amt)));
      var b = Math.min(255, Math.round(((num >> 8) & 0x00ff) * (1 + amt)));
      var g = Math.min(255, Math.round((num & 0x0000ff) * (1 + amt)));
      var newColor = g | (b << 8) | (r << 16);
      return newColor;
    }

    function clamp(coord) {
      coord.theta = ((coord.theta + Math.PI) % (2 * Math.PI)) - Math.PI;
      coord.phi = ((coord.phi + Math.PI) % (2 * Math.PI)) - Math.PI;
      return coord;
    }

    function toSpherical(pos) {
      return clamp({
        theta: (DEGREES_TO_RADIANS * (pos[0] + bp.referencePos[0])) / 100,
        phi: (DEGREES_TO_RADIANS * (pos[1] + bp.referencePos[1])) / 100,
        radius: 200.2,
      });
    }

    function toCartesian(coord) {
      var x = coord.radius * Math.sin(coord.theta) * Math.cos(coord.phi);
      var y = coord.radius * Math.cos(coord.theta);
      var z = coord.radius * Math.sin(coord.theta) * Math.sin(coord.phi);
      return new THREE.Vector3(x, y, z);
    }

    function renderBP() {
      var reference = toSpherical([0, 0]);
      var orig = [
        controls.minPolarAngle,
        controls.maxPolarAngle,
        controls.minAzimuthAngle,
        controls.maxAzimuthAngle,
      ];

      controls.minPolarAngle = reference.theta;
      controls.maxPolarAngle = reference.theta;
      controls.minAzimuthAngle = reference.phi;
      controls.maxAzimuthAngle = reference.phi;
      controls.update();

      controls.minPolarAngle = orig[0];
      controls.maxPolarAngle = orig[1];
      controls.minAzimuthAngle = orig[2];
      controls.maxAzimuthAngle = orig[3];
      controls.update();

      buildingsGroup = new THREE.Group();
      beltsGroup = new THREE.Group();
      scene.add(buildingsGroup);
      scene.add(beltsGroup);

      var positions = {};

      for (let i = 0; i < bp.copiedBuildings.length; i++) {
        const building = bp.copiedBuildings[i];
        var model = modelsData[building.modelIndex];
        var stick = new THREE.Object3D();
        var point = toCartesian(toSpherical(building.cursorRelativePos));
        stick.lookAt(point);
        buildingsGroup.add(stick);
        var geometry = new THREE.BoxGeometry(...model.size);
        //const material = new THREE.MeshBasicMaterial({color: 0xffff00});

        const material = new THREE.MeshPhongMaterial({
          color: LightenDarkenColor(model.color || 0xcccccc, -0.5), // model.color || 0xcccccc,
          emissive: LightenDarkenColor(model.color || 0xcccccc, 0),
          emissiveIntensity: 0.5,
          reflectivity: 1,
          side: THREE.FrontSide,
        });
        var mesh = new THREE.Mesh(geometry, material);
        mesh.rotateZ(THREE.Math.degToRad(building.cursorRelativeYaw));
        mesh.position.set(0, 0, 200.2);

        mesh.data = building;
        stick.add(mesh);

        var geo = new THREE.EdgesGeometry(geometry);
        var mat = new THREE.LineBasicMaterial({
          color: 0xffffff,
          transparent: true,
          opacity: 0.3,
          linewidth: 2,
        });

        var wireframe = new THREE.LineSegments(geo, mat);
        wireframe.rotateZ(THREE.Math.degToRad(building.cursorRelativeYaw));
        wireframe.position.set(0, 0, 200.2);
        stick.add(wireframe);

        positions[building.originalId] = point;
        buildings.push(mesh);
      }
      const markerGeometry = new THREE.SphereGeometry(0.3, 4, 4);
      const markerMaterial = new THREE.MeshBasicMaterial({
        color: 0xff0000
      });
      console.log('start');
      var beltMap = {};
      for (let i = 0; i < bp.copiedBelts.length; i++) {
        const belt = bp.copiedBelts[i];
        var point = toCartesian(toSpherical(belt.cursorRelativePos));
        positions[belt.originalId] = point;
        beltMap[belt.originalId] = belt;
      }
      var lanes = [];
      for (let i = 0; i < bp.copiedBelts.length; i++) {
        let belt = bp.copiedBelts[i];

        if (belt.seen) continue;

        var lane = [];
        do {
          lane.push(positions[belt.originalId]);
          belt.seen = true;
          belt = beltMap[belt.outputId];
        } while (belt && !belt.seen);
        if (belt) {
          lane.push(positions[belt.originalId]);
        }
        belt = beltMap[bp.copiedBelts[i].backInputId];

        if (belt) {
          do {
            lane.unshift(positions[belt.originalId]);
            belt.seen = true;
            belt = beltMap[belt.backInputId];
          } while (belt && !belt.seen);
        }
        if (belt) {
          lane.unshift(positions[belt.originalId]);
        }
        lanes.push(lane);
      }

      var resolution = new THREE.Vector2(window.innerWidth, window.innerHeight);
      lanes.forEach((lane) => {
        const materialA = new MeshLineMaterial({
          color: 0xff0000,
          linewidth: 0.7,
        });

        const lineGeo = new MeshLine();
        lineGeo.setPoints(lane);

        const line = new THREE.Mesh(lineGeo.geometry, materialA);
        beltsGroup.add(line);
      });
    }

    function animate() {
      requestAnimationFrame(animate);
      render();
    }

    const raycaster = new THREE.Raycaster();
    raycaster.params = {
      Mesh: {
        threshold: 0.5
      },
      Line: {
        threshold: 1
      },
      LOD: {},
      Points: {
        threshold: 1
      },
      Sprite: {},
    };
    const mouse = new THREE.Vector2();
    var lastMouseEvent;

    function onMouseMove(event) {
      lastMouseEvent = event;
      mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
      mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    }

    function onClick(event) {
      if (selected) {
        console.log(selected.data);
      }
    }

    var selected;
    var tooltip = tooltipContainer;

    function render() {
      // update the picking ray with the camera and mouse position
      raycaster.setFromCamera(mouse, camera);

      var cameraDistance = controls.target.distanceTo(
        controls.object.position
      );
      controls.rotateSpeed = cameraDistance ** 2 / controls.maxDistance ** 2;
      // calculate objects intersecting the picking ray
      const intersects = raycaster.intersectObjects(buildings);

      if (intersects.length && selected != intersects[0]) {
        if (selected) {
          selected.material.emissiveIntensity = 0.5;
        }
        document.body.style.cursor = 'pointer';
        selected = intersects[0].object;
        selected.material.emissiveIntensity = 1;
        var data = selected.data;
        tooltip.style.display = 'block';
        tooltip.innerHTML = `
                <p>originalId  ${data.originalId}</p>
                <p>modelIndex: ${data.modelIndex}</p>
                <p>recipeId:   ${data.recipeId}</p>`;
      } else {
        if (selected) {
          selected.material.emissiveIntensity = 0.5;
        }
        document.body.style.cursor = '';
        selected = null;
        tooltip.style.display = 'none';
      }

      if (selected && lastMouseEvent) {
        tooltip.style.left = lastMouseEvent.clientX - 60 + 'px';
        tooltip.style.top = lastMouseEvent.clientY - 80 + 'px';
      }

      renderer.render(scene, camera);
    }

    init();
    renderBP();
    animate();

    window.addEventListener('pointermove', onMouseMove, false);
    window.addEventListener('click', onClick, false);
  }
}
