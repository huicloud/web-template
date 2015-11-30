/**
 * 分时和K线图
 *
 * 使用方式和参数说明如下
 *
 * 创建图表
 * new Chart(container, options)
 *
 * container {!Element|jQueryElement} 容器元素，将在该元素中创建图表
 * options {
 *   types {Array<string>=} 需要创建的图表类型，可选值为'min'|'klineDay'|'klineWeek'|'klineMonth'，默认为['min','klineDay','klineWeek','klineMonth'],
 *                         当types数组长度超过一个时将会创建一个tabs（div.tabs.tab-style-b）用作图表间切换
 *
 *   dataProvider {!Object} 图表数据提供商对象，用作请求和处理图表中的数据，需提供的接口方法如下：
 *     getInitData(type, done) 用作K线请求初始时间轴数据
 *     getData(type, start, end, done) 用作K线请求指定位置的完整数据
 *     subscribeData(type, done) 用作分时图订阅实时数据
 *
 *   mini {boolean=} 是否创建迷你话图表，默认false
 *                   暂时只支持分时图，迷你话的分时图区别在于不创建成交量Column图，鼠标移动时不创建tooltip，y轴和x轴的tick简化
 *
 *   其它参数字段将作为所有图表共同参数透传给Highcharts的创建方法 <http://api.highcharts.com/highstock>
 *   例如: new Chart(container, {
 *          ...
 *          chart: {                 // 将覆盖默认设置的550 * 320的图表大小
 *            width: 300,
 *            height: 200
 *          }
 *        })
 *
 *   另各个图表类型名称的参数将作为该类型图表参数透传给Highcharts的创建方法
 *   例如: new Chart(container, {
 *          ...
 *          min: {                   // 隐藏分时图的成交量图
 *            xAxis: {
 *              labels: {y:null}
 *            },
 *            yAxis: [
 *              {height: null},
 *              {height: null},
 *              {height: 0}
 *            ]
 *          }
 *        })
 * }
 */
(function(global) {

  // 复写Highcharts中判断涨跌的代码，解决开盘收盘价格相同时上涨下跌判断错误的问题
  var seriesTypes = Highcharts.seriesTypes;
  seriesTypes.candlestick.prototype.getAttribs = function() {
    seriesTypes.column.prototype.getAttribs.apply(this, arguments);
    var series = this,
      options = series.options,
      stateOptions = options.states,
      upLineColor = options.upLineColor || options.lineColor,
      upColor = options.upColor || series.color,
      hoverStroke = stateOptions.hover.upLineColor || upLineColor,
      selectStroke = stateOptions.select.upLineColor || upLineColor,
      seriesUpPointAttr = Highcharts.merge(series.pointAttr),
      upColorProp = series.upColorProp;

    seriesUpPointAttr[''][upColorProp] = upColor;
    seriesUpPointAttr.hover[upColorProp] = stateOptions.hover.upColor || upColor;
    seriesUpPointAttr.select[upColorProp] = stateOptions.select.upColor || upColor;
    seriesUpPointAttr[''].stroke = upLineColor;
    seriesUpPointAttr.hover.stroke = hoverStroke;
    seriesUpPointAttr.select.stroke = selectStroke;

    var lastPoint = null;
    Highcharts.each(series.points, function (point) {

      // 开盘价小于收盘或者等于时该价格比昨天的收盘高都是上涨
      if (point.open < point.close || point.up) {
        point.pointAttr = seriesUpPointAttr;
      }
      lastPoint = point;
    });
  };
  Highcharts.PlotLineOrBand.prototype.update = function (newOptions){
    var plotBand = this;
    Highcharts.extend(plotBand.options, newOptions);
    if (plotBand.svgElem) {
      plotBand.svgElem.destroy();
      plotBand.svgElem = undefined;
      plotBand.render();
    } else {
      plotBand.render();
    }
  };
  Highcharts.theme = {
    colors: ["#7cb5ec", "#f7a35c", "#90ee7e", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
      "#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
    chart: {
      backgroundColor: null,
      style: {
        //fontFamily: "Dosis, sans-serif"
      }
    },
    title: {
      style: {
        fontSize: '16px',
        fontWeight: 'bold',
        textTransform: 'uppercase'
      }
    },
    tooltip: {
      borderWidth: 0,
      backgroundColor: 'rgba(255,255,255,0)',
      shadow: false
    },
    legend: {
      itemStyle: {
        fontWeight: 'bold',
        fontSize: '13px'
      }
    },
    yAxis: {
      gridLineColor: '#eee'
    },
    xAxis: {
      gridLineWidth: 1,
      gridLineColor: '#eee',
      tickLength: 0,
      labels: {
        style: {
          fontSize: '12px'
        }
      }
    },
    plotOptions: {
      candlestick: {
        color: 'green',
        lineColor: 'green',
        upColor: 'red',
        upLineColor: 'red'
      }
    }

  };

  // Apply the theme
  Highcharts.setOptions(Highcharts.theme);
  Highcharts.setOptions({
    global: {
      useUTC: false
    }
  });

  var tabNames = {
    min: '分时图',
    kline1Min: '1分钟',
    kline5Min: '5分钟',
    kline15Min: '15分钟',
    kline30Min: '30分钟',
    kline60Min: '60分钟',
    klineDay: '日K线',
    klineWeek: '周K线',
    klineMonth: '月K线'
  };

  var groupingUnits = [[
    'week',                         // unit name
    [1]                             // allowed multiples
  ], [
    'month',
    [1]
  ]];
  var klineOptions = {
    chart: {
      animation: false,
      width: 550,
      height: 320,
      marginLeft: 35
    },
    navigator: {
      adaptToUpdatedData: false,
      height: 20,
      margin: 0,
      xAxis: {
        dateTimeLabelFormats: {
          day: '%m-%e',
          week: '%m-%e',
          month: '%Y-%m',
          year: '%Y'
        }
      }
    },
    scrollbar: {
      liveRedraw: false
    },
    xAxis: {
      tickPosition: 'inside',
      labels: {
        x: 0,
        y: -47
      },
      dateTimeLabelFormats: {
        millisecond:"%H:%M",
        second:"%H:%M",
        minute:"%H:%M",
        hour:"%H:%M",
        day: '%m-%e',
        week: '%m-%e',
        month: '%Y-%m',
        year: '%Y'
      }
    },
    yAxis: [{
      //gridLineWidth: 0,
      //minorTickInterval: 'auto',
      top: '5%',
      height: '70%',
      lineWidth: 1,
      opposite:false,
      labels: {
        align: 'right',
        x: 0,
        y: 4
      }
    }, {
      //gridLineWidth: 0,
      top: '85%',
      height: '15%',
      offset: 0,
      lineWidth: 1,
      opposite:false,
      labels: {
        align: 'right',
        x: 0,
        y: 4,
        useHTML: true,
        formatter: function() {
          if (this.value === 0) {
            return 0;
          } else if (this.value > 1000 * 1000 * 1000) {
            return Highcharts.numberFormat(this.value / (1000 * 1000 * 1000), 0) + 'b';
          } else if (this.value > 1000 * 1000) {
            return Highcharts.numberFormat(this.value / (1000 * 1000), 0) + 'm';
          } else if (this.value > 1000) {
            return Highcharts.numberFormat(this.value / 1000, 0) + 'k';
          } else {
            return Highcharts.numberFormat(this.value, 0);
          }
        }
      },
      tickPositioner: function() {

        var max = this.dataMax;

        if (max) {
          var tickDistance = max / 3,
            positions = [0];

          for (var i = 1; i <= 3; i++) {
            positions.push(Math.round(tickDistance * i));
          }
          return positions;
        }
        return null;
      }
    }],
    rangeSelector: {
      selected : 1,
      enabled: false
    },
    tooltip: {
      crosshairs: [true, true],
      positioner: function () {
        return { x: 10, y: -5 };
      },
      useHTML: true,
      borderWidth: 0,
      borderRadius: 0,
      headerFormat: '{point.key} ',
      shadow: false,
      dateTimeLabelFormats: {
        millisecond:"%Y年%m月%e日",
        second:"%Y年%m月%e日",
        minute:"%Y年%m月%e日",
        hour:"%Y年%m月%e日",
        day:"%Y年%m月%e日",
        week:"%Y年%m月%e日",
        month:"%Y年%m月%e日",
        year:"%Y年%m月%e日"
      }
    },
    series: [{
      type: 'candlestick',
      name: '价格',
      data: [],
      dataGrouping: {
        //units: groupingUnits,
        groupPixelWidth: 1,
        dateTimeLabelFormats: {
          millisecond:["%Y年%m月%e日"],
          second:["%Y年%m月%e日"],
          minute:["%Y年%m月%e日"],
          hour:["%Y年%m月%e日"],
          day:["%Y年%m月%e日"],
          week:["%Y年%m月%e日"],
          month:["%Y年%m月%e日"],
          year:["%Y年%m月%e日"]
        }
      },
      tooltip: {
        pointFormatter : function() {
          return '|<span>开盘'+this.open+'</span>|<span>收盘'+this.close+'</span>|<span>最高'+this.high+'</span>|<span>最低'+this.low+'</span>';
        }
      },
      turboThreshold: 0
    }, {
      type: 'column',
      name: '成交量',
      data: [],
      yAxis: 1,
      dataGrouping: {
        //units: groupingUnits,
        groupPixelWidth: 1
      },
      tooltip: {
        pointFormatter : function() {
          return '|<span>成交量'+this.y+'</span>';
        }
      },
      turboThreshold: 0
    }, {
      type: 'spline',
      name: 'MA5',
      yAxis: 0,
      color: '#8080ff',
      lineWidth: 1,
      data: [],
      dataGrouping: {
        groupPixelWidth: 1
      },
      turboThreshold: 0,
      tooltip: {
        pointFormatter : function() {
          return '<span style="display:block; position: absolute; left: 20px; top: 18px; color: #8080ff;">MA5:'+this.y+'</span>';
        }
      }
    }, {
      type: 'spline',
      name: 'MA10',
      yAxis: 0,
      color: '#ffcf88',
      lineWidth: 1,
      data: [],
      dataGrouping: {
        groupPixelWidth: 1
      },
      turboThreshold: 0,
      tooltip: {
        pointFormatter : function() {
          return '<span style="display:block; position: absolute; left: 200px; top: 18px; color: #ffcf88;">MA10:'+this.y+'</span>';
        }
      }
    }, {
      type: 'spline',
      name: 'MA30',
      yAxis: 0,
      color: '#ff8080',
      lineWidth: 1,
      data: [],
      dataGrouping: {
        groupPixelWidth: 1
      },
      turboThreshold: 0,
      tooltip: {
        pointFormatter : function() {
          return '<span style="display:block; position: absolute; left: 420px; top: 18px; color: #ff8080;">MA30:'+this.y+'</span>';
        }
      }
    }],
    credits: false
  };

  var klineMinOptions = $.extend(true, {}, klineOptions, {
    series: [{
      dataGrouping: {
        enabled: false
      }
    }, {
      dataGrouping: {
        enabled: false
      }
    }],
    tooltip: {
      dateTimeLabelFormats: {
        millisecond:"%m月%e日 %H:%M",
        second:"%m月%e日 %H:%M",
        minute:"%m月%e日 %H:%M",
        hour:"%m月%e日 %H:%M",
        day:"%m月%e日 %H:%M",
        week:"%m月%e日 %H:%M",
        month:"%m月%e日 %H:%M",
        year:"%m月%e日 %H:%M"
      }
    }
  });

  var chartOptions = {
    min: {
      chart: {
        animation: false,
        width: 550,
        height: 320,
        marginTop: 20
        //marginLeft: 25
      },
      scrollbar : {
        enabled : false
      },
      navigator: {
        enabled : false
      },
      rangeSelector: {
        enabled: false
      },
      tooltip: {
        crosshairs: [true, true],
        positioner: function () {
          return { x: 10, y: -5 };
        },
        borderWidth: 0,
        borderRadius: 0,
        headerFormat: '{point.key} ',
        shadow: false,
        dateTimeLabelFormats: {
          millisecond:"%Y年%m月%e日 %H:%M",
          second:"%Y年%m月%e日 %H:%M",
          minute:"%Y年%m月%e日 %H:%M",
          hour:"%Y年%m月%e日 %H:%M",
          day:"%Y年%m月%e日",
          week:"%Y年%m月%e日",
          month:"%Y年%m月%e日",
          year:"%Y年%m月%e日"
        }
      },
      xAxis: {
        tickPosition: 'inside',
        labels: {
          x: 0,
          y: -70
        },
        dateTimeLabelFormats: {
          day: '%m. %e',
          week: '%m. %e',
          month: '%Y-%m',
          year: '%Y'
        },
        //tickInterval: 60 * 60 * 1000,
        tickPositioner: function() {
          if (this.ordinalPositions) {
            var positions = this.ordinalPositions,
              startIndex = positions.length > 241 ? 15 : 0,
              mini = this.chart.mini,
              interval = mini ? 60 : 30,
              ticks = $.map(new Array(parseInt(positions.length / interval) + 1), function(nullData, index) {
                if (interval * index === 120) {
                  return positions[startIndex + interval * index] + 90 * 60 * 1000;
                } else {
                  return positions[startIndex + interval * index];
                }
              });
            ticks.info = {
              unitName: "minute",
              higherRanks: {},
              totalRange: ticks[ticks.length - 1] - ticks[0]
            };
            return ticks;
          }
        }
      },
      yAxis: [{
        lineWidth: 1,
        showFirstLabel: false,
        showLastLabel: false,
        startOnTick: true,
        endOnTick: true,
        opposite: false,
        height: '70%',
        labels: {
          align: 'right',
          x: 0,
          y: 4,
          useHTML: true,
          formatter: function() {
            var closePrice = this.chart.closePrice;
            var color = this.value > closePrice ? '#f00' : this.value < closePrice ? '#198019' : '#000';
            return '<span style="color: ' + color + '">' + Math.round(this.value * 100) / 100 + '</span>';
          }
        },
        plotLines: [{
          width: 1,
          color: 'gray',
          dashStyle: 'dash',
          zIndex: 10
        }],
        tickPositioner: function() {

          // 根据昨收价和现在数据计算tick（保证昨收价显示在中间）
          var closePrice = this.chart.closePrice, max = this.series[0].dataMax, min = this.series[0].dataMin;

          if (this.chart.positions) {
            return this.chart.positions;
          } else if (closePrice && max && min) {

            // 保证昨收价在中间
            var maxDistance = Math.max(Math.abs(max - closePrice), Math.abs(min - closePrice));

            var tickAmount = this.chart.mini ? 3 : 4,
              tickDistance = maxDistance / tickAmount,
              positions = [closePrice],
              ratioPositions = [0];

            var up = closePrice, down = closePrice;
            for (var i = 1; i <= tickAmount + 1; i++) {

              // 最后一个算一半
              if (i === tickAmount + 1) {
                tickDistance = tickDistance / 2;
              }

              up = up + tickDistance;
              positions.push(up);
              ratioPositions.push((up - closePrice) / closePrice);

              down = down - tickDistance;
              positions.unshift(down);
              ratioPositions.unshift((down - closePrice) / closePrice);
            }

            this.chart.positions = positions;
            this.chart.ratioPositions = ratioPositions;
            return positions;
          }
          return null;
        }
      }, {
        startOnTick: true,
        endOnTick: true,
        linked: 0,
        tickPositioner: function() {
          return this.chart.ratioPositions;
        },
        showFirstLabel: false,
        showLastLabel: false,
        height: '70%',
        gridLineWidth: 0,
        labels: {
          useHTML: true,
          align: 'left',
          x: 0,
          y: 4,
          formatter: function() {
            var color = this.value > 0 ? '#f00' : this.value < 0 ? '#198019' : '#000';
            return '<span style="color: ' + color + '">' + Math.round((this.value * 100) * 100) / 100 + '%' + '</span>';
          }
        }
      }, {
        top: '78%',
        height: '22%',
        offset: 0,
        lineWidth: 1,
        opposite:false,
        labels: {
          align: 'right',
          x: 0,
          formatter: function() {
            if (this.value > 10 * 1000 * 1000 * 1000) {
              return Highcharts.numberFormat(this.value / (1000 * 1000 * 1000), 1) + 'b';
            } else if (this.value > 10 * 1000 * 1000) {
              return Highcharts.numberFormat(this.value / (1000 * 1000), 1) + 'm';
            } else if (this.value > 10 * 1000) {
              return Highcharts.numberFormat(this.value / 1000, 1) + 'k';
            } else {
              return Highcharts.numberFormat(this.value, 1);
            }
          }
        },
        tickPositioner: function() {

          var max = this.dataMax;

          if (max) {
            var tickDistance = max / 3,
              positions = [0];

            for (var i = 1; i <= 3; i++) {
              positions.push(Math.round(tickDistance * i));
            }
            return positions;
          }
          return null;
        }
      }],
      series: [{
        type: 'area',
        name: '价格',
        color: '#0095d9',
        lineWidth: 1,
        data: [],
        tooltip: {
          valueDecimals: 2,
          pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y}</b> | '
        },
        dataGrouping: {
          enabled: false
        },
        fillColor : {
          linearGradient : {
            x1: 0,
            y1: 0,
            x2: 0,
            y2: 1
          },
          stops : [
            [0, Highcharts.getOptions().colors[0]],
            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
          ]
        }
      }, {
        type: 'spline',
        name: '均价',
        color: '#eb5f15',
        lineWidth: 1,
        data: [],
        tooltip: {
          valueDecimals: 2,
          pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y}</b> | '
        },
        dataGrouping: {
          enabled: false
        }
      }, {
        type: 'column',
        name: '成交量',
        data: [],
        color: "#d69c11",
        yAxis: 2,
        dataGrouping: {
          enabled: false
        }
      }],
      credits: false
    },
    kline1Min: $.extend(true, {}, klineMinOptions),
    kline5Min: $.extend(true, {}, klineMinOptions),
    kline15Min: $.extend(true, {}, klineMinOptions),
    kline30Min: $.extend(true, {}, klineMinOptions),
    kline60Min: $.extend(true, {}, klineMinOptions),
    klineDay: $.extend(true, {}, klineOptions),
    klineWeek: $.extend(true, {}, klineOptions),
    klineMonth: $.extend(true, {}, klineOptions)
  };

  function createTabBar(types) {
    var tabBar = $('<ul>').addClass('tabs tab-style-b');
    $.each(types, function(index, type) {
      var tabItem = $('<li><a hidefocus="true" href="javascript:void(0)">'+tabNames[type]+'</a></li>');
      tabItem.attr('id', 'tab_chart_' + type);
      tabItem.data('type', type);
      tabBar.append(tabItem);
    });

    tabBar.on('click', 'li', function(event) {
      $('.active', tabBar).removeClass('active');
      $(event.currentTarget).addClass('active');
    });
    return tabBar;
  }

  /**
   * 创建图形
   * @param {!Element} container 容器元素
   * @param {{ types: Array }=} options 参数
   *           types: 需要画的图类型，总共四种'min'|'klineDay'|'klineWeek'|'klineMonth'，可设置一个或多个，默认不设置为4个都显示
   * @constructor
   */
  var Chart = function(container, options) {

    var self = this;

    if (!container || !(container.length > 0 ? (container = container[0]) : container)['appendChild']) {
      throw new Error('第一个参数，容器元素必须为dom元素');
    }
    options = options || {};

    self._container = $(container);
    self._options = options;
    var volumeUpColor = '#f06f6b', volumeDownColor = '#6fc76f';
    options.dataProvider.klineAdapter = function(time, open, high, low, close, volume, up) {
      return [{
        x: time,
        open: open,
        high: high,
        low: low,
        close: close,
        up: up
      }, {
        x: time,
        y: volume,
        color: up === true ? volumeUpColor : volumeDownColor
      }];
    };

    var types = options.types || ['min', 'kline5Min', 'klineDay', 'klineWeek', 'klineMonth'];

    // 如果types为多个则创建出tab栏做切换
    if (types.length > 1) {
      var tabBar = createTabBar(types);
      tabBar.on('click', function(event) {
        var selectTabItem = $(event.target).closest('li');
        var type = selectTabItem.data('type');
        if (type) {
          self.changeChart(type);
        }
      });

      // 清除容器中原内容
      self._container.empty().append(tabBar);

      tabBar.find('li').eq(0).click();
    } else {
      var type = types[0];
      self.changeChart(type);
    }
  };

  Chart.prototype.changeChart = function(type) {
    var chartPanel = this._container.find('.panel').hide().filter('.' + type);

    if (chartPanel.length === 0) {
      if (type.indexOf('min') >= 0) {
        chartPanel = this.createMinChart(type);
      } else if (type.indexOf('kline') >= 0) {
        chartPanel = this.createKlineChart(type);
      }

    }
    chartPanel.show();
  };

  Chart.prototype.createMinChart = function(type) {
    var self = this;
    var chartPanel = $('<div>').addClass('panel ' + type).appendTo(this._container);

    var mini = this._options.mini;

    var chartOption = $.extend(true, {}, chartOptions[type],
      mini === true ? {
        tooltip: {crosshairs: false, enabled: false},
        plotOptions: { series: { states: { hover: { enabled: false } } }},
        xAxis: {tickPosition: 'outside', labels: { y: null}},
        yAxis: [{height: null}, {height: null}]
      } : {}, self._options, self._options[type]);
    if (mini === true) {
      chartOption.yAxis.pop();
      chartOption.series.pop();
    }

    chartPanel.highcharts('StockChart', chartOption, function() {
      var chart = this;
      chart.mini = mini;

      chart.showLoading();

      self._options.dataProvider.subscribeData(type, function(data, closePrice) {
        var series = chart.series[0];
        chart.closePrice = closePrice;

        chart.positions = null;
        series.setData(data[0]);

        chart.yAxis[0].plotLinesAndBands[0].update({
          value: closePrice
        });

        chart.series[1].setData(data[1]);
        chart.yAxis[1].update();

        if (mini !== true) {

          // 将成交量数据从数组转换为对象，添加颜色字段
          var volumes = [], prices =data[0], volumeUpColor = '#f06f6b', volumeDownColor = '#6fc76f', lastPrice = closePrice;

          $.each(data[2], function(index, point) {
            var price = prices[index][1] || prices[index]['y'],
              up = (price > lastPrice) || (price === lastPrice && price > closePrice);
            volumes.push({
              x: point[0],
              y: point[1],
              color: up ? volumeUpColor : volumeDownColor
            });
            lastPrice = price;
          });
          chart.series[2].setData(volumes);
        }

        chart.hideLoading();
      });

    });
    return chartPanel;
  };

  Chart.prototype.createKlineChart = function(type, splitType) {
    var self = this;
    var chartPanel = $('<div>').addClass('panel ' + type).appendTo(this._container);
    chartPanel.data['splitType'] = splitType;

    var chart = chartPanel.highcharts('StockChart', $.extend(true, {}, chartOptions[type], {
      xAxis: {
        events: {
          afterSetExtremes: function(event) {
            var chart = this.chart;
            if (event.max && event.min) {
              chart.showLoading();
              self._options.dataProvider.getData(type, splitType, event.min, event.max, function(data) {
                chart.series[0].setData(data[0]);
                chart.series[1].setData(data[1]);

                chart.hideLoading();
              });

              // MA均线，暂时只支持不复权
              //if (!splitType && ma.indexOf(type) >= 0) {
                self._options.dataProvider.getMAData(type, splitType, event.min, event.max, function(data) {
                  chart.series[2].setData(data[0]);
                  chart.series[3].setData(data[1]);
                  chart.series[4].setData(data[3]);
                });
              //}
            }
          }
        }
      }
    }, self._options, self._options[type]), function() {
      var chart = this;

      chart.showLoading();

      // 初始数据
      var initStartDate, initEndDate;
      self._options.dataProvider.getInitData(type, splitType, function(data) {
        chart.series[5].setData(data);

        var length = data.length;
        var initStartDate = data[Math.max(length - 80, 0)][0];
        var initEndDate = data[Math.max(length - 1, 0)][0];
        chart.xAxis[0].setExtremes(initStartDate, initEndDate);
      });
    });

    return chartPanel;
  };
  global.Chart = Chart;
})(window);