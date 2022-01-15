let ExtensionHooks = {};

// TODO: make this more configurable? ie. don't import disabled extensions

// import { MyHooks } from "../../../deps/some_extension/assets/js/extension"
import { GeolocateHooks } from "./../../../forks/bonfire_geolocate/assets/js/extension"

Object.assign(ExtensionHooks, GeolocateHooks)
export { ExtensionHooks }
