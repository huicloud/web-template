// 加载数据模块
(function (global) {

  var dataStoreOptions = {
    min: {
      serviceUrl: '/quote/min',
      pushInterval: 15 * 1000
    },
    klineDay: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '1day'
      }
    },
    klineWeek: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: 'week'
      }
    },
    klineMonth: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: 'month'
      }
    },
    kline1Min: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '1min'
      }
    },
    kline5Min: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '5min'
      }
    },
    kline15Min: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '15min'
      }
    },
    kline30Min: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '30min'
      }
    },
    kline60Min: {
      serviceUrl: '/quote/kline',
      otherParams: {
        period: '60min'
      }
    }
  };
  
  var ChartDataProvider = function(obj) {
    if (!window.DataStore) {
      throw new Error('DataStore不存在');
    }

    this.obj = obj;
    this._cache = {};
  };

  ChartDataProvider.prototype._klineDataAdapter = function(data) {
    var prices = [];
    var volumes = [];
    var self = this;
    $.each(data, function(index, eachData) {
      var result = self.klineAdapter(eachData['ShiJian'] * 1000, eachData['KaiPanJia'], eachData['ZuiGaoJia'], eachData['ZuiDiJia'], eachData['ShouPanJia'], eachData['ChengJiaoLiang'], eachData['up']);
      prices.push(result[0]);
      volumes.push(result[1]);
    });
    return [prices, volumes];
  };

  ChartDataProvider.prototype._getDataFromCache = function(type, splitType, start, end) {
    splitType = splitType || '';
    var cache = this._cache[type + splitType];

    // 如果内部数据缓存存在
    if (cache) {
      if (!start) {
        return cache;
      }
      var startIndex;
      var fullIndex;
      var data = $.grep(cache, function(eachData, i) {
        var time = eachData['ShiJian'] * 1000;
        if (fullIndex === undefined && eachData._full) {
          fullIndex = i;
        }
        if (time >= start && time <= end) {
          if (startIndex === undefined) {
            startIndex = i;
          }
          return true;
        }
      });

      if (data[0]._full) {
        this._start = null;
        this._count = null;
        return this._klineDataAdapter(data);
      } else {

        // 记录最后一次拖动的位置作为MA指标的请求参数
        this._start = startIndex - cache.length;
        this._count = fullIndex ? fullIndex - startIndex : null;
        return {
          start: startIndex,
          count: fullIndex ? fullIndex - startIndex : null
        }
      }
    }
    return false;
  };

  ChartDataProvider.prototype._addCache = function(type, splitType, data, startIndex) {
    if (!data) {
      return;
    }
    splitType = splitType || '';
    var cache = this._cache[type + splitType];

    if (!cache) {
      cache = data;
      cache._map = {};
      var lastClose = 0, yesterdayClose = 0;
      $.each(cache, function(index, eachData) {

        var time = eachData['ShiJian'];
        cache._map[time] = eachData;

        // 时间中的日期变化了，则记录为yesterdayClose
        if (index > 0) {
          var yesterdayTime = cache[index - 1]['ShiJian'];
          if (new Date(yesterdayTime * 1000).getDate() !== new Date(time * 1000).getDate()) {
            yesterdayClose = cache[index - 1]['ShouPanJia'];
          }
        }

        // 添加一个字段，用昨收和今收比较判断是上涨还是下跌，用作成交量的颜色标记
        var close = eachData['ShouPanJia'];
        eachData.up = (close > lastClose) || (close === lastClose && close > yesterdayClose) ;
        lastClose = close;
      });
      this._cache[type + splitType] = cache;
    } else {

      if (startIndex < 0) {
        startIndex = cache.length + startIndex;
      }

      // 合并cache
      $.each(data, function(index, eachData) {
        delete eachData['ShouPanJia'];
        delete eachData['ShiJian'];
        $.extend(cache[index + startIndex], eachData, {_full: true});
      });
    }
  };

  // 对于分时，订阅数据
  ChartDataProvider.prototype.subscribeData = function(type, done) {

    var self = this;
    var minTime;
    var minPrice;
    var minVolume;
    var minAverage;
    var ZuoShou;

    // 请求昨收价格
    new DataStore({
      serviceUrl: '/quote/dyna',
      fields: ['ZuoShou']
    }).query({obj: self.obj}).then(function (data) {
      ZuoShou = data[self.obj]['ZuoShou'];

      var dataStore = self._minDataStore = new DataStore(dataStoreOptions[type]);
      dataStore.subscribe({obj: self.obj}, function (data) {
        data = data[self.obj];
        if (!minTime) {
          // 初始化分时数据

          var startTime = data[0] && data[0].ShiJian * 1000;
          if (!startTime) {

            // 默认开始时间当天9:30
            var now = new Date();
            now.setHours(9);
            now.setMinutes(30);
            now.setSeconds(0);
            now.setMilliseconds(0);

            startTime = now.getTime();
          }

          var start15 = (new Date(startTime).getMinutes() === 15);

          minTime = [];
          minPrice = [];
          minVolume = [];
          minAverage = [];
          var time = startTime;
          var oneMinute = 1 * 60 * 1000;

          for (var i = 0, length = start15 ? 4 * 60 + 15 : 4 * 60; i <= length; i++) {
            minTime.push(time);
            minPrice.push([time, null]);
            minVolume.push([time, null]);
            minAverage.push([time, null]);
            time = time + oneMinute;
            if (start15 ? i === (2 * 60 + 15) : i === (2 * 60)) {
              time += 90 * oneMinute;
            }
          }
        }

        if (data.length > 0) {
          $.each(data, function (i, eachData) {
            var time = eachData.ShiJian * 1000,
              index = minTime.indexOf(time);
            minPrice[index] = [time, eachData['ChengJiaoJia'] || null];
            minAverage[index] = [time, eachData['JunJia'] || null];
            minVolume[index] = [time, eachData['ChengJiaoLiang'] || null];
          })
        }
        done([minPrice, minAverage, minVolume], ZuoShou);
      });
    });
  };

  function _format(date, format) {
    var d, k, o;
    o = {
      "M+": date.getMonth() + 1,
      "d+": date.getDate(),
      "h+": date.getHours(),
      "m+": date.getMinutes(),
      "s+": date.getSeconds(),
      "q+": Math.floor((date.getMonth() + 3) / 3),
      "S": date.getMilliseconds()
    };
    if (/(y+)/.test(format)) {
      format = format.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
    }
    for (k in o) {
      d = o[k];
      if (new RegExp("(" + k + ")").test(format)) {
        format = format.replace(RegExp.$1, RegExp.$1.length === 1 ? d : ("00" + d).substr(("" + d).length));
      }
    }
    return format;
  }

  function formatDateTime(time) {
    return _format(new Date(parseInt(time)), 'yyyyMMdd-hhmmss');
  }

  // k线请求数据
  ChartDataProvider.prototype.getData = function(type, splitType, start, end, done) {

    var self = this;
    var data = this._getDataFromCache(type, splitType, start, end);
    if (!(data instanceof Array)) {
      var _start, _count;
      if (data !== false) {
        _start = data.start;
        _count = data.count;
      } else {

        // 初始请求最近100条数据
        _start = -80;
      }
      var obj = this.obj;
      var dataStore = new DataStore($.extend({}, dataStoreOptions[type], {
        fields: ['KaiPanJia', 'ZuiGaoJia', 'ZuiDiJia', 'ChengJiaoLiang', 'ShiJian']
      }));

      // 加1是因为云平台的数据从1计数
      dataStore.query({obj: obj, split: splitType, start: _start + 1, count: _count}).then(function(data) {
        self._addCache(type, splitType, data[obj], _start);
        done(self._getDataFromCache(type, splitType, start, end));
      });
    } else {
      done(data);
    }
  };

  // 请求初始数据，k线的时间范围数据
  ChartDataProvider.prototype.getInitData = function(type, splitType, done) {
    var self = this;
    var kline = this._getDataFromCache(type, splitType);
    if (kline) {
      done($.map(kline, function(eachData, index) {
        return [[eachData['ShiJian'] * 1000, eachData['ShouPanJia']]];
      }));
    } else {
      new DataStore($.extend({}, dataStoreOptions[type], {
        fields: ['ShiJian', 'ShouPanJia']
      })).query({obj: this.obj, split: splitType}).then(function(data) {
          var kline = data[self.obj];
          self._addCache(type, splitType, kline);
          done($.map(kline, function(eachData, index) {
            return [[eachData['ShiJian'] * 1000, eachData['ShouPanJia']]];
          }));
        });
    }
  };

  ChartDataProvider.prototype.getMAData = function(type, splitType, start, end, done) {
    var cacheKey = [type, splitType, 'MA'].join(':'),
      self = this,
      cache = this._cache[cacheKey],
      startTime = start,
      endTime = end,
      result;

    // 缓存存在
    //if (cache && (endTime = cache.start) < startTime) {
    if (cache && !this._start) {
      result = cache;
    } else {
      cache = (cache || (this._cache[cacheKey] = []));
      cache._map = cache._map || {};

      // 请求数据
      result = new $.Deferred();

      new DataStore({
        serviceUrl: '/indicator/calc'
      }).query({
          obj: this.obj,
          name: 'MA',
          split: splitType,
          period: {klineDay: '1day', klineWeek: 'week', klineMonth: 'month'}[type],
          parameter: '5,10,30',
          start: this._start,
          count: this._count
          // 暂不支持
          //begin_time: _format(new Date(startTime), 'yyyyMMdd-000000'),
          //end_time: _format(new Date(endTime), 'yyyyMMdd-000000')
        }).then(function (data) {
          var MA = data && data[self.obj];

          if (MA && MA.ShuJu instanceof Array) {

            // 添加进缓存
            //cache.unshift.apply(cache, MA.ShuJu);

            var shiJu = MA.ShuJu;
            for (var i = shiJu.length; i > 0; i--) {
              var eachData = shiJu[i - 1];
              var time = eachData['ShiJian'];
              if (!cache._map[time]) {
                cache._map[time] = true;
                cache.unshift(eachData);
              }
            }

            // 记录开始时间应该取第一条数据或者请求时间中较小的一个
            cache.start = Math.min(start, MA.ShuJu[0]['ShiJian'] * 1000);
          }
          result.resolve(cache);
        });
    }
    $.when(result).then(function(cache) {
      var MA1 = [], MA2 = [], MA3 = [], MA4 = [], MA5 = [], MA6 = [];
      $.each(cache, function(index, eachData) {
        var time = eachData['ShiJian'] * 1000;
        if (time > end) {

          // 停止循环
          return false;
        } else if (time >= start) {
          var MA = eachData['JieGuo'];
          MA1.push([time, MA[0]]);
          MA2.push([time, MA[1]]);
          MA3.push([time, MA[2]]);
          MA4.push([time, MA[3]]);
          MA5.push([time, MA[4]]);
          MA6.push([time, MA[5]]);
        }
      });
      done([MA1, MA2, MA3, MA4, MA5, MA6]);
    });
  };

  // 关闭数据请求
  ChartDataProvider.prototype.close = function(type) {

    // 暂时只考虑分时做订阅数据，所以只取消分时数据订阅
    this._minDataStore.cancel();
  };

  global.ChartDataProvider = ChartDataProvider;
})(window);