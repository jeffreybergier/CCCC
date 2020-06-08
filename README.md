# Ｃ四つ - Currency Converter Coding Challenge

## Summary
A sample app that uses SwiftUI and Combine with the [CurrencyLayer.com]( https://currencylayer.com/documentation) API to make a simple currency converter application. A requirement of this project was to cache the result of the API Fetch for 30 minutes before fetching it again. The projects include tests that test the model and fetching / caching code. Also, the project makes use of Swift Previews to make modifying the UI very fast and easy.

## Objects of Note
### `Cacher`
An object that wraps a Combine `Publisher` to fetch and cache any `Codable` type. `Cacher` uses closures that return `Futures` for the "Original Load" "Cache Write" and "Cache Read". This makes it extremely flexible. It can fetch and write the data to anywhere. Its also easy to test. 


