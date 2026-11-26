# WiFiBruter Sileo / Cydia Repository

Add this repo to Sileo or Cydia:

```
https://dung-x.github.io/Wifi-bruter-repo/
```

## Packages

- **com.kilo.wifibruter** — WiFiBruter (iOS 12 & iOS 15 compatible)

## How packages are synced

The `build.yml` workflow in [`dung-x/Wifi-bruter`](https://github.com/dung-x/Wifi-bruter) builds the `.deb`. The `sync.yml` workflow here downloads the artifact and regenerates the `Packages` index automatically.

## Manual install

Download the latest `.deb` from the [GitHub Actions artifacts](https://github.com/dung-x/Wifi-bruter/actions) of the `Wifi-bruter` repo and install with:

```bash
dpkg -i com.kilo.wifibruter_*.deb
```
