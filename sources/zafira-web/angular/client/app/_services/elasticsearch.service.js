(function () {
    'use strict';

    angular
        .module('app.services')
        .factory('ElasticsearchService', ['$q', 'esFactory', '$location', 'SettingsService', '$rootScope', ElasticsearchService])

    function ElasticsearchService($q, esFactory, $location, SettingsService, $rootScope) {

        var instance;

        $rootScope.$on('event:elasticsearch-toolsInitialized', function (event, data) {
            if(data.url) {
                instance = getInstance(data.url.value);
            } else {
                alertify.error('Cannot initialize elasticsearch host and port');
            }
        });

        var service = {};

        service.ping = ping;
        service.search = search;

        return service;

        function ping() {
            return $q(function (resolve, reject) {
                instance.ping({
                    requestTimeout: 30000
                }, function (error) {
                    resolve(! error);
                });
            });
        }

        function search(index, query, page, size) {
            return $q(function (resolve, reject) {
                var searchParams = {
                    index: index,
                    from: page && size ? (page - 1) * size : undefined,
                    size: size,
                    q: query,
                    body: {
                        sort: [
                            {
                                timestamp: {
                                    order: "asc"
                                }
                            }
                        ]
                    }
                };
                elasticsearch(searchParams).then(function (rs) {
                    resolve(rs);
                });
            });
        }

        function elasticsearch(params) {
            return $q(function (resolve, reject) {
                waitUntilInstanceInitialized(function () {
                    instance.search(params, function (err, res) {
                        if(err) {
                            reject(err);
                        } else {
                            resolve(res.hits.hits);
                        }
                    });
                });
            });
        }

        function getInstance(url) {
            instance = instance || esFactory({
                host: url,
                ssl: {
                    rejectUnauthorized: false
                }
            });
            return instance;
        }

        function waitUntilInstanceInitialized(func) {
            var elasticsearchWatcher = $rootScope.$watchGroup(['elasticsearch.url'], function (newVal) {
                if(newVal[0] && newVal[1]) {
                    func.call();
                    elasticsearchWatcher();
                }
            });
        };
    }
})();
