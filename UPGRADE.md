## 0.0.6

* add Babelfish::Chronometer
* add Babelfish.guess_frequency


## 0.0.5

* improve error messages with line, row, context
* add Quandl::Error::Standard, all errors inherit from Error::Standard


## 0.0.4

* remove quandl_data as a dependency


## 0.0.3

* Add Quandl::Data as a add_runtime_dependency
* refactor Babelfish::Data to inherit from Quandl::Data
* refactor specs


## 0.0.1

* replace Cleaner.process return clean_array, header with Quandl::Babelfish::Data.new( clean_array, headers: header )
* refactored error
* added header extraction support
* init