# MapyKit - Native Mapy.cz Swift SDK

MapyKit is native [Mapy.cz](https://mapy.cz) SDK written in Swift. MapyKit uses native `MKMapView` under the hood, so it's compatible with all your current map logic out of the box.

This project is currently in early development stage, framework APIs may change over time.

<p align="center">
    <img src="Resources/main.jpg" alt="MapyKit example preview">
</p>

## Installation

Only manual installation from source is supported at the moment. Support for [Carthage](https://github.com/Carthage/Carthage) and [CocoaPods](https://cocoapods.org) comming soon.

## Usage

Once you have downloaded project source all you have to do is to insert the map view into view hierarchy. The Mapy.cz maps are rendered using `MapyView`, subclass of `MKMapView`:

```swift
let mapView = MapyView()

view.addSubview(mapView)
mapView.setExtendedMapType(mapType: .touristic)
```

Since the view is subclass of `MKMapView`, you can use all API provided by standard map view (e.g. set `delegate` or use map annotations).

### Map types

MapyKit supports multiple map types. By default, the `ExtendedMapType.standard` map is rendered. You can change this behavior using `setExtendedMapType(mapType:)` method:

```swift
mapView.setExtendedMapType(mapType: .touristic)
```

Supported map types are listed below.

| Type | Description | Preview |
|----|----|----|
| `.standard` | Standard map view (default) | [preview](https://mapy.cz/zakladni) |
| `.touristic` | Standard map with highlighted hiking trails | [preview](https://mapy.cz/turisticka) |
| `.winter` | Map of winter resorts | [preview](https://mapy.cz/zimni) |
| `.satelite` | Satelite map (without labels) | [preview](https://mapy.cz/letecka) |
| `.hybrid` | Satelite map (with native labels) | [preview](https://mapy.cz/letecka) |
| `.geography` | Geography map | [preview](https://mapy.cz/zemepisna) |
| `.historical` | Historical map from 19th century | [preview](https://mapy.cz/19stoleti) |
| `.textMap` | Text-only map | [preview](https://mapy.cz/textova) |
| `.in100Years` | Czech Republic in 100 years | [preview](https://mapy.cz/ceskoza100) |

## Example

See working example of MapyKit with customizable map type in [Example](Example) directory.

## Known issues

Custom map overlay is drawn using `MKTileOverlayRenderer`, which is set using `delegate` API of internal `MKMapView`. In order to preserve the original API, the delegation forwarding is used. This delegation currently doesn't work well and may (and probably will) crash your app. As workaround, don't set the `.delegate` property of `MapyView`.

## License

This repository is licensed under [MIT](LICENSE).
