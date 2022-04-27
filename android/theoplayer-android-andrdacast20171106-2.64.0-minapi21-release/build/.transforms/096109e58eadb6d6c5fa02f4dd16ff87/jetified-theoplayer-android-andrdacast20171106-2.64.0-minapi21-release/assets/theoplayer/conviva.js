var brand = "<!-- CONVIVA_DEVICE_BRAND -->";
var manufacturer = "<!-- CONVIVA_DEVICE_MANUFACTURER -->";
var model = "<!-- CONVIVA_DEVICE_MODEL -->";
var version = "<!-- CONVIVA_DEVICE_VERSION -->";
var createDeviceMetadata = function (brand, manufacturer, model, version) {
    window.theoplayerDeviceMetadata = {
        brand: brand,
        manufacturer: manufacturer,
        model: model,
        version: version
    };
};
createDeviceMetadata(brand, manufacturer, model, version);
