<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-资金流向</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript" src="js/highcharts.js"></script>
    <script type="text/javascript">
    $(function(){
    	
    	var dataStore = new DataStore({
    		idProperty: "id",
			dataType: "json",
	        serviceUrl: "/quote/l2stat"
	    });
    	
    	(function($){
    		//一日资金流向
    		zjlx(1, "yrzjlx");
	    	//五日资金流向
    		zjlx(5, "wrzjlx");
	    	//三十日资金流向
    		zjlx(30, "srzjlx");
    	})(jQuery);
    	
    	function zjlx(days, divId) {
    		dataStore.query({
            	obj: currCode,
            	field: "ShiJian,DaDanLiuRuJinE,DaDanLiuChuJinE",
            	start: (0-days)
            }).then(function(result) {	

            	var zjData = [];
            	var liuru = 0, liuchu = 0;
            	
            	$.each(result[currCode],function(i,item){
            		if (item.DaDanLiuRuJinE) {
	            		liuru += item.DaDanLiuRuJinE;
            		}
            		if (item.DaDanLiuChuJinE) {
	            		liuchu += item.DaDanLiuChuJinE;
            		}
            	});
            	
            	zjData.push(Math.round(liuru/100)/100);
            	zjData.push(Math.round(liuchu/100)/100);
            	zjData.push(Math.round((liuru-liuchu)/100)/100);
            
            	if (zjData && zjData.length > 0) {
	            	draw(zjData);
            	}
            });
    		
    		function draw(d) {
    			var options = {
                        chart: {
                            renderTo: divId,
                            type: "column"
                        },
                        title: {
                            text: days+"日资金流向",
                            style: { "color": "#333333", "fontSize": "14px" }
                        },
                        subtitle: {
                            text: "单位：万元",
                            align: "right"
                        },
                        colors: ["#7cb5ec", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#8085e8", "#8d4653", "#91e8e1"],
                        xAxis: {
                            categories: ["流入","流出","净额"],
                            gridLineWidth: 1
                        },
                        yAxis: {
                            title: {
                                text: null
                            },
                            labels: {
                                format: "{value:.2f}"
                            },
                            plotLines: [{
                                color: "#808080"
                            }],
                            offset: 1
                        },
                        tooltip: {
                            valueSuffix: ""
                        },
                        legend: {
                            enabled: false
                        },
                        plotOptions: {
                            series: {
                                borderWidth: 0,
                                dataLabels: {
                                    enabled: true,
                                    format: "{point.y:.2f}",
                                    align: "left",
                                    rotation: -45,
                                    x: -10,
                                    y: 10,
                                    color: "#808080",
                                    shadow: false
                                }
                            }
                        },
                        series: [{
                            name: "Brands",
                            colorByPoint: true,
                            data: d
                        }]
                    };
                    
            	var chart = new Highcharts.Chart(options);
    		}
    		
    	}
    	
    	//最近30天数据
    	(function($){
    		var lastest30Body = $("#lastest30Body");
    		var mairuZd, mairuDd; //买入中单、买入大单
			var maichuZd, maichuDd; //卖出中单、卖出大单
    		
    		dataStore.query({
    			obj: currCode,
    			start: -30
            }).then(function(data) {
				var arr = [];
   				var result = $.makeArray(data[currCode]).reverse();
    			$.each(result,function(i,item){
    				mairuZd = item.MaiRuZhongDanBiLi - item.MaiRuDaDanBiLi; //实际买入中单=买入中单-买入大单
    				mairuDd = item.MaiRuDaDanBiLi - item.MaiRuTeDaDanBiLi; //实际买入大单=买入大单-买入特大
    				maichuZd = item.MaiChuZhongDanBiLi - item.MaiChuDaDanBiLi;
    				maichuDd = item.MaiChuDaDanBiLi - item.MaiChuTeDaDanBiLi;
    				
    				arr.push("<tr><td class='date'>"+new Date(item.ShiJian*1000).format("yyyy-MM-dd")+"</td>");
    				arr.push("<td class='DaDanLiuRuJinE'>"+(item.DaDanLiuRuJinE/10000).toFixed(2)+"</td>");
    				arr.push("<td class='DaDanLiuChuJinE'>"+(item.DaDanLiuChuJinE/10000).toFixed(2)+"</td>");
    				arr.push("<td class='DaDanJinE'>"+((item.DaDanLiuRuJinE-item.DaDanLiuChuJinE)/10000).toFixed(2)+"</td>");
    				arr.push("<td class='MaiRuTeDaDanBiLi'>"+item.MaiRuTeDaDanBiLi+"</td>");
    				arr.push("<td class='MaiRuDaDanBiLi'>"+mairuDd+"</td>");
    				arr.push("<td class='MaiRuZhongDanBiLi'>"+mairuZd+"</td>");
    				arr.push("<td class='MaiChuTeDaDanBiLi'>"+item.MaiChuTeDaDanBiLi+"</td>");
    				arr.push("<td class='MaiChuDaDanBiLi'>"+maichuDd+"</td>");
    				arr.push("<td class='MaiChuZhongDanBiLi'>"+maichuZd+"</td></tr>");
    			});
    			
    			lastest30Body.html(arr.join(""));
            }).then(function(){
            	
	    		var firstTr = lastest30Body.find("tr:first");
	    		dataStore.subscribe({
	    			obj: currCode,
	    			start: -1
	    		}, {}, function(data) {
	    			
	    			var item = data[currCode][0];	console.log(item);
	    			mairuZd = item.MaiRuZhongDanBiLi - item.MaiRuDaDanBiLi; //实际买入中单=买入中单-买入大单
    				mairuDd = item.MaiRuDaDanBiLi - item.MaiRuTeDaDanBiLi; //实际买入大单=买入大单-买入特大
    				maichuZd = item.MaiChuZhongDanBiLi - item.MaiChuDaDanBiLi;
    				maichuDd = item.MaiChuDaDanBiLi - item.MaiChuTeDaDanBiLi;
	    			
	    			firstTr.find(".date").html(new Date(item.ShiJian*1000).format("yyyy-MM-dd")).end()
	    			.find(".DaDanLiuRuJinE").html((item.DaDanLiuRuJinE/10000).toFixed(2)).end()
	    			.find(".DaDanLiuChuJinE").html((item.DaDanLiuChuJinE/10000).toFixed(2)).end()
	    			.find(".DaDanJinE").html(((item.DaDanLiuRuJinE-item.DaDanLiuChuJinE)/10000).toFixed(2)).end()
	    			.find(".MaiRuTeDaDanBiLi").html(item.MaiRuTeDaDanBiLi).end()
	    			.find(".MaiRuDaDanBiLi").html(mairuDd).end()
	    			.find(".MaiRuZhongDanBiLi").html(mairuZd).end()
	    			.find(".MaiChuTeDaDanBiLi").html(item.MaiChuTeDaDanBiLi).end()
	    			.find(".MaiChuDaDanBiLi").html(maichuDd).end()
	    			.find(".MaiChuZhongDanBiLi").html(maichuZd).end();
	    			
	    		});
            	
            });
    		
    		
    	})(jQuery);
    	
    });
    </script>
</head>
<body>
    <div class="wrapper">
        
        <div class="site-header">
            <!-- 导航栏  -->
            <jsp:include page="navigation.jsp"></jsp:include>
        </div>
        
        <div class="site-content">
            <div class="container">
                
                <!-- sk-board -->
                <jsp:include page="board.jsp"></jsp:include>
                
                <div class="two-columns clearfix">
                    
                    <!-- left-column -->
                    <div class="left-column">
                        
                        <!-- 资金流向 -->
                        <div class="zjlx clearfix">
                            <ul class="tabs tab-style-c">
                                <li class="active"><a href="javascript:void(0);">资金流向</a></li>
                            </ul>
                            
                            <div class="zjlx-content clearfix">
                                <div id="yrzjlx" style="width:260px;height:300px;float:left"></div>
                                <div id="wrzjlx" style="width:260px;height:300px;float:left"></div>
                                <div id="srzjlx" style="width:260px;height:300px;float:left"></div>
                            </div>
                        </div>
                        <!-- 资金流向 -->
                        
                        <!-- 最近30天数据 -->
                        <div class="zjsj clearfix">
                            <ul class="tabs tab-style-c">
                                <li class="active"><a href="javascript:void(0);">最近30天数据</a></li>
                            </ul>
                            <div class="zjsj-content">
                                <table width="100%" class=" table-style-e colorTable">
                                    <thead>
                                        <tr>
                                        	<th>日期</th>
                                            <th>资金流入（万）</th>
                                            <th>资金流出（万）</th>
                                            <th>资金净额（万）</th>
                                            <th>特大买</th>
                                            <th>大单买</th>
                                            <th>中单买</th>
                                            <th>特大卖</th>
                                            <th>大单卖</th>
                                            <th>中单卖</th>
                                        </tr>
                                    </thead>
                                    <tbody id="lastest30Body"></tbody>
                                </table>
                            </div>
                        </div>
                        <!-- 最近30天数据-->
                        
                    </div>
                    <!-- left-column -->
                    
                    <!-- right-column -->
                    <div class="right-column">
                        <!-- 我的自选 -->
                        <jsp:include page="common_mystocks.jsp"></jsp:include>
                        <!-- 投资评级 -->
                        <jsp:include page="investGrade.jsp"></jsp:include>
                    </div>
                    <!-- right-column -->
                </div>
            </div>
        </div>
    </div>
</body>
</html>