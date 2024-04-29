'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "3ed9bc2fe9218c72b42724b693047678",
"assets/assets/arial.ttf": "5995c725ca5a13be62d3dc75c2fc59fc",
"assets/assets/arial_bold.ttf": "e29d16fb2d50bff249b5f4412c6868f5",
"assets/assets/images/arial.ttf": "5995c725ca5a13be62d3dc75c2fc59fc",
"assets/assets/images/dfsdfs.png": "2ac9f965906e3d20b61c938f3acf0653",
"assets/assets/images/fondo-login.jpg": "f5ad9049cb841950ef448dfe58f930e8",
"assets/assets/images/ic_launcher%2520-%2520copia----tccc.png": "14a2bf2633040f02c8169a0903c22eb4",
"assets/assets/images/ic_launcher%2520-%2520copia.png": "37b920a6d9d064dfb2e9fd9f5be154c9",
"assets/assets/images/ic_launcher%2520-%2520tccc.png": "360a6bbfce051c5c404dfc4d8ac45d0b",
"assets/assets/images/ic_launcher.png": "361b6364858e5c10e7b95b420f31fd72",
"assets/assets/images/ic_launchersddssd.png": "2ac9f965906e3d20b61c938f3acf0653",
"assets/assets/images/ic_launcher_negro.png": "9faa5af9df17a0c241ea8bccfc35427b",
"assets/assets/images/ic_launcher_negro222.png": "84b894f0793550be04291fbc11315490",
"assets/assets/images/Inv_A_las_Rocas-tcccc.png": "360a6bbfce051c5c404dfc4d8ac45d0b",
"assets/assets/images/Inv_A_las_Rocas.png": "361b6364858e5c10e7b95b420f31fd72",
"assets/assets/images/usuario.jpg": "4e7f13bf95aab58a77ae386a60f69eff",
"assets/assets/images/wqeqwew.jpg": "bf16dd188171023c9276ed2bb5bd1a0c",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "8fdb3360d1ea099d2bd48dc9979ebcbd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"favicon---.png": "5dcef449791fa27946b3d35ad8803796",
"favicon.png": "cb514c41da1aa8ac9562eb5b7dea3d3a",
"flutter.js": "a85fcf6324d3c4d3ae3be1ae4931e9c5",
"icons/Icon-192---.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-192.png": "9501560002e1c442679c858980887b27",
"icons/Icon-512---.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-512.png": "d9bb31483cd842bfc1f503ed48f90553",
"icons/Icon-maskable-192---.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-192.png": "9501560002e1c442679c858980887b27",
"icons/Icon-maskable-512%20-%20copia.png": "d9bb31483cd842bfc1f503ed48f90553",
"icons/Icon-maskable-512---.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "65100a830112594dee981cfc578518dd",
"/": "65100a830112594dee981cfc578518dd",
"main.dart.js": "5418aff544a40ddcd75b2e13c37190e5",
"manifest.json": "c9c6e178b1a37f4ddb356807fa7235ed",
"sqflite_sw.js": "956c8c891e383d810e98bd8c25f33002",
"sqlite3.dart-sqlite3-2.4.0.tar.gz": "61a743c99b370dd084f2b6ba5db5937c",
"sqlite3.dart-sqlite3-2.4.0.zip": "7824a1269c5bfc5fd73f83b6cfa32f5a",
"sqlite3.debug.wasm": "8b7d30030122ddb8c091f8d1029219b4",
"sqlite3.wasm": "8e4ed39391f4e06cd7ae00a2692cc91c",
"version.json": "a757f2ad7297daf7e1a16e66a17fbdfe"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
