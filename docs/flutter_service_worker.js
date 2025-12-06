'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "1a4a097e17ceee03ae7a8df9253ac51a",
".git/config": "25738b28fc58233b469d8c08017a7fec",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "f59727967bdaa651a6209de4a9fcbfa3",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "5c7ab33e8c4d62d2c7243387521e8260",
".git/logs/refs/heads/gh-pages": "5c7ab33e8c4d62d2c7243387521e8260",
".git/objects/02/1d4f3579879a4ac147edbbd8ac2d91e2bc7323": "9e9721befbee4797263ad5370cd904ff",
".git/objects/04/0699bf7bede7449d7d2c808efebe4a4da75a59": "5bff6b42abb4a925a163723a115d3b91",
".git/objects/0a/5c02d6b81c6d5b5565a5785c2595c54c93a4c2": "91d0f1a9a487b258fe868ea9c6628261",
".git/objects/12/042e028f77a76fe47b94135b75ec42beef7479": "c244b93959041f9b9851d1bca1679206",
".git/objects/16/368cae0e4c39468f96138c2a4ea39eb4eea6b8": "ca29c178b50433a0efde933be7513826",
".git/objects/1d/3860625853f19716b06228d1a19f1ef2fb906b": "ffb38bc1f3f37d87423c8bd285b58b06",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/22/f511bd3757d591a6fa02293f121414c3d03a84": "eb7d88355d9fb35c40b1aab52ea9df59",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/44/71f8bb9b561f138ffa348cdfe8072cf96f9052": "e9033bbba13e2b9d605e68cd1c08f24d",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/47/37cac685cb09c7bd5bccf6306915f144ab38ef": "eeecd019abc86338f099e1510f37fe69",
".git/objects/4b/e2b53e80b77c0e6a35cc507ed8086768de92fd": "7dffe9a80acaa02bff7ea1c8a813f7d7",
".git/objects/4c/6db9f6f3eea62041d62946b3549d5aa75565e1": "31f52a0d8fe14ac556ad974def062e8a",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/4e/835ba1b4337d69b81c87172db042bb0c3793b3": "90c59f437f97c0df3dfbfc94b403737c",
".git/objects/4f/ad38d3d5881e763f0ec67e86e626f96ae2738e": "589da2ad0984d8917bb4ef446a9c303e",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/50/18b3922f4d59e4b51d0822b6115e7eb45a6cae": "7f3ea6079865eb12ca1ef6c1617f50ee",
".git/objects/57/fc8d743dbf28e94b019c045fcbb42679dee132": "0c6c2beb7c8cc727254a3b8af88619d6",
".git/objects/62/d08094575ab40573857026e121811acbede1ef": "edf72c3af6725cf7e073c26ead0b4a07",
".git/objects/6a/907678c4967b96eaade001684649a9a1e35c7a": "c68730efc53fcea30224c18766169699",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/88/c54e8c6cbe011436e27574df74a84d7c2ee0e7": "04e4ae3fa58d8a86c9bde272ef61e8e2",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/89/e2d473a49446b87107d5a03590094980f1e34c": "3924403ca6ce92c048b20c0668bdd4ab",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8b/6368509db5ef1fa248a71a015d236e99cebdb3": "42dffaa6d6ff322ba4804bafb0c16c81",
".git/objects/8c/e0b35c86f6b58debb845c6808dabf34821ed2b": "702fb4229635860fdeb61cac2340c00c",
".git/objects/91/80b7ddb01499fa99ad99db9613713b7eebd22e": "0e20f8fa305915dfe00e08d0d13020ec",
".git/objects/97/c2dacda3d4ba262ce93d382bd18eba7a944ad2": "4b06910924a24a0306813804bf3183f5",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/98/31ada07941c4cea35504862840f0be426d3209": "8357cce4d786ad22c45e4d0057c60194",
".git/objects/9a/adeed662dfa921e7706b46e8089bc93df67324": "f55f1dbbfb6be7286707fb7694e02b7a",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/a0/9294e26d43ffde53d1c0e084b70728a57bf727": "2c0ae85f7f4f49c092119f7f797338e8",
".git/objects/a4/326ec51ccba4da416e1b6f42c0c2ca5cc97d0f": "54cacc375bb8ce7ebe6899e449663a18",
".git/objects/a9/ecfe0dea2b985a61b87f48bb1fd06c5a9fbaec": "99ca259d5320ed3890e09eb28fb0b538",
".git/objects/b0/74514ebdda8db02472925339574ad4c77f0e7e": "367e96be7e6bf9fe1f4268be0d90fb67",
".git/objects/b1/5821d5c37dd2f93d4b5a6a2d5744bdf7154121": "d33184eeba8433337bc09fff353350e4",
".git/objects/b5/fde8c62f0c570c6bdb2898454cd0e435b20ceb": "f7bc070603a05bbb25c8a6adb74ebdbf",
".git/objects/b6/359b0865bde465c07c3ce96a78be2d1a6e352e": "ae4b77d65d0033cd48c18f03c72af280",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/c1/8bf24b3c4e9859413ff3d44b25160aef3b38ac": "27214db6feda5efaf03081229289a532",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/c6/5db01eb81cace15259ea9a019e492f3e093aa6": "f2d8fee721bd64e4fd32b7fa4596daa1",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/cc/a83271b373bbd65bb491e1970ee0d1fcab28f0": "9b096c7be18f10e6a9660651df32c2fe",
".git/objects/cf/c04970ee3b19428faf1a08eb17741e5e537a4e": "62ad41371fa84f5b7925fa421df0587b",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/49d766de29066db278b639c4dbd4acca1c06c3": "07153a3c3893753d724563e316e554a2",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/e3/d579307714c14c3bb6a19461c0a28aad3c3fb3": "929a57dcdbfce580cdc1ac27775920d6",
".git/objects/e3/e9ee754c75ae07cc3d19f9b8c1e656cc4946a1": "14066365125dcce5aec8eb1454f0d127",
".git/objects/e5/8dbca1bf8832941a84f014c43798561309ce72": "83e84ded85a98942a3a2578ad4bd0858",
".git/objects/e6/14c2235ca0f7436993f8d5915eaa68c0107668": "26e577bde3a5c9d56ff0bc2cb906a572",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f9/1ac28b0a87ada35955e2bcf23bf2e1e35cf33d": "06b7a2c8e6a5a96302acd4805723f798",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/refs/heads/gh-pages": "333da4c6b61c068e60f1bbc319cbb47c",
"assets/AssetManifest.bin": "3dc9415cf77d6e20e31f5001a4478770",
"assets/AssetManifest.bin.json": "98f1aabcf0e19cd26cca8567dfcc0709",
"assets/AssetManifest.json": "4b1179491692ae00d538dc32f0875350",
"assets/assets/automation.png": "af58f4f9ac1c3e33041e532f6c41df22",
"assets/assets/bg.jpg": "671f35af7337d60ecf093d36866bf79d",
"assets/assets/dashboard.png": "d7924e92123c2f6157d46bfdda485017",
"assets/assets/data.xlsx": "80364ed9d89e42ecf6efeac54bd5edeb",
"assets/assets/drip_irrigation.png": "9b922f2ae3e417b6b995d9d9b5e62abe",
"assets/assets/farmdata.xlsx": "0d2d9e2d6890a4c842fded79f5d9840a",
"assets/assets/farm_sensor_data_500_samples.xlsx": "c352d921616e41989abc0f15ea9bec64",
"assets/assets/finance.png": "a49d78503086302fa8f33f77934363a8",
"assets/assets/harvest.png": "d9102d72583ea218004f16408fc5426e",
"assets/assets/home.png": "afc451bd4c4f279ffa6f4400e75fee55",
"assets/assets/irrigation.jpg": "b335afe59bdc71b206bd532815835097",
"assets/assets/lens.png": "dbdd56cd9a31485abb131976a6015432",
"assets/assets/logo.png": "4f33fa8502a64321fdc06a43c1cde2bd",
"assets/assets/ml.png": "9e4351847153ec8d759f3e942fd4e5ca",
"assets/assets/scale.png": "ae6a05aa328eab40553ebee0cd2158bf",
"assets/assets/seed.png": "75be6a9ec84e967bc2e72be036bce29a",
"assets/assets/sensors.json": "b9b154beb6021f202b2b2beea4e30034",
"assets/assets/site1.png": "60141c96451a8f52fd15143e5d383719",
"assets/assets/site2.png": "ff8891c3a565e244ad41caa1629c3449",
"assets/assets/site3.png": "db318a221b3ca39b48af97cdb7d71922",
"assets/assets/site4.png": "205c401b2f2d30ba62e8b49d25a5c133",
"assets/assets/tank.png": "867dca60e9b5accb2005f728047fd7f9",
"assets/assets/weather.jpg": "e0edfcd65829f656a3ebed0c40b59125",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "97d1f741eebcb58334f0238c825a569d",
"assets/NOTICES": "a9c0debdbc208c0bf6be35b3a093880d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "4fbf98a9881f82750f2a7f78cf99de0e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "0fb70c461c56fe5b306016bbc7fe0ca1",
"/": "0fb70c461c56fe5b306016bbc7fe0ca1",
"main.dart.js": "95318fdaffc4983f1945b7af3f7f0ae5",
"manifest.json": "ddc6422ec0851393a895c2a66a9e1f66",
"version.json": "02f27cd44a79fa6a6d660dd01a05ae12"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
