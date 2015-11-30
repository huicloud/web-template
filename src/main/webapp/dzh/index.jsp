<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE HTML >
<html>
  <head>
	<title>首页</title>
	<link type="text/css" media="all" rel="stylesheet" href="<c:url value="/dzh/css/unit.css"/>" />
	<%@include file="head.jsp" %>
	<script type="text/javascript" src="<c:url value="/dzh/js/highstock.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/dzh/js/chart.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/dzh/js/chartDataProvider.js"/>"></script>
	<script type="text/javascript">
	$(function(){
		
		//分时K线
	    (function($){
	    	var dataProvider;
	    	var kline = $(".kline-chart");
		    $("#scul li").click(function(){
				$(this).addClass("active").siblings().removeClass("active");
				drawKLine($(this).attr("sc"));
			});
		    
			function drawKLine(sc) {
				//if (dataProvider) dataProvider.close();
				dataProvider = new ChartDataProvider(sc);
	            var chart = new Chart($("#kline_"+sc), {
	                dataProvider: dataProvider,
	                chart: { width: 350, height: 200 },
	                types: ["min"],
	                mini: true
	            });
			}
			
			$("#scul li:eq(0)").trigger("click");
	    	
	    })(jQuery);
		
	  	//键盘宝
	    (function($){
	    	kbspirit($("#searchtext"), function(stockCode) {
	    		window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + stockCode;
	    	});
	    })(jQuery);
		
	  	//处理自选股
		(function($){
			var myCode = [], resultCode = 1;
			var mystockDynaDataStore = new DataStore({ //动态行情数据源 专门处理 自选股
			    serviceUrl: "/stkdata"
			});
			
			$.ajax({
				type: "get",
				url: mystockurl+"/myStock.do",
				dataType: "jsonp",
				jsonpCallback: "jsonpCallback",
				success: function(result) {
					// Object { resultMsg="自选股查询成功",  data=[2],  resultCode=0}
					resultCode = result.resultCode;
					if (result.resultCode == 0) {
						var arr = result.data;
						$.each(arr,function(i, item){
							myCode.push(item.STOCKCODE);
		    			});
					}
				},
				complete: function() {
					if (resultCode == 0 && myCode.length>0) {
						var arr = [];
						$.each(myCode,function(i, item){
							arr.push("<tr id='mystock_"+item+"'>");
							arr.push("<td class='obj'></td><td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td><td class='ZhangFu'></td>");
							arr.push("<td class='ZhenFu'></td></tr>");
		    			});
						$("#mystockBody").html(arr.join(""));
						
						mystockDynaDataStoreSubscribe(mystockDynaDataStore, myCode);
					}
				}
			});
			
			function mystockDynaDataStoreSubscribe(dynaDataStore, stkCode) {
				dynaDataStore.subscribe({
					obj: stkCode,
					field: "ZhongWenJianCheng,ZuiXinJia,ZhangFu,ZhenFu"
				}, {}, function(data) {
					if (data instanceof Error) {
						setTimeout(function(){
							mystockDynaDataStoreSubscribe(dynaDataStore, stkCode);
						}, 3000);
					} else {
						for (x in data) {
							var dynaData = data[x];
							if (dynaData) {	
								valMyStockDynaData(dynaData);
							}
						}
					}
				});
			}   

			//根据推送的动态行情数据填充响应的元素
			function valMyStockDynaData(d) {
				var mystock_stk = $("#mystock_"+d.Obj);
				//处理自选
				if (mystock_stk.length>0) {
					mystock_stk.find(".obj").html(d.Obj).end()
					.find(".ZhongWenJianCheng").html(d.ZhongWenJianCheng).end()
					.find(".ZuiXinJia").html(d.ZuiXinJia).addClass(d.ZhangFu>0?"red":"green").end()
					.find(".ZhangFu").html(d.ZhangFu+"%").addClass(d.ZhangFu>0?"red":"green").end()
					.find(".ZhenFu").html(d.ZhenFu+"%").end()
					;
				}
			}
		})(jQuery);
		
	});
	
	</script>
  </head>
  
  <body>
    <div style="width:425px;height:670px;">
        <div class="stock-wrapper">
            <div class="stock-index">
                <ul id="scul" class="tabs tab-style clearfix">
                    <li sc="SH000001"><a href="javascript:void(0);">上证指数</a></li>
                    <li sc="SZ399001"><a href="javascript:void(0);">深证指数</a></li>
                    <li sc="SH000300"><a href="javascript:void(0);">沪深300</a></li>
                    <li sc="SZ399005"><a href="javascript:void(0);">中小板</a></li>
                    <li sc="SZ399006"><a href="javascript:void(0);">创业板</a></li>
                </ul>
                
                <div class="panel" style="display:block">
                    <div id="kline_SH000001"></div>
                </div>
                <div class="panel">
                    <div id="kline_SZ399001"></div>
                </div>
                <div class="panel">
                    <div id="kline_SH000300"></div>
                </div>
                <div class="panel">
                    <div id="kline_SZ399005"></div>
                </div>
                <div class="panel">
                    <div id="kline_SZ399006"></div>
                </div>
            </div>
            
            <div class="stock-quick clearfix">
                <div class=""><a href="#">国金免费开户</a></div>
                <div><a href="#">佣金千分之三</a></div>
            </div>
            
            <div class="mystock">
                <div class="mystock-top">
                    <h3>我的自选股</h3>
                    <div class="mystock-search">
                        <input type="text" accesskey="s" id="searchtext" class="searchtext" name="keywords" autocomplete="off" value="代码/名称/拼音" />
                    </div>
                </div>
                <div class="mystock-content">
                    <table width="100%" class="table-style">
                        <col width=""><col width=""><col width=""><col width=""><col width="">
                        <thead>
                            <tr><th>代码</th><th>名称</th><th>最新价</th><th>涨跌幅</th><th>振幅</th></tr>
                        </thead>
                        <tbody id="mystockBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
  </body>
</html>
