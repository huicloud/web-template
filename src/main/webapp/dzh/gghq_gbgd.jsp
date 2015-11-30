<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-股本股东</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript" src="js/highcharts.js"></script>
    <script type="text/javascript">
    $(function(){

    	new DataStore({ //股东户数
            serviceUrl: "/f10/gdjc/gdhs"
        }).query({
        	obj: currCode,
        	start: -4,
            count: 4
        }).then(function(result) {
        	var d = $.makeArray(result[currCode]).reverse();
    	
        	var strArr = [];
        	var trArr = ["date","Gdzhs","Hbzj","Hbbh","Rjcg"];
        	
        	for(var i = 0; i < trArr.length; i++) {
				strArr.push(getGdhsTablePart(i));
	        	$.each(d,function(j, item){
					strArr.push("<td>" + (trArr[i]=="date" ? item[trArr[i]].substring(0,10) : item[trArr[i]]) + "</td>");
	            });
        		strArr.push("</tr>");
        	}
        	
        	$("#gdhsBody").html(strArr.join(""));
        	
        	function getGdhsTablePart(i) {
            	var s = "";
            	switch(i){
        	    	case 0: s = "<tr class='graybg date'><td>&nbsp;</td>"; break;
        	    	case 1: s = "<tr class='Gdzhs'><td align='left'>股东人数</td>"; break;
        	    	case 2: s = "<tr class='Hbzj'><td align='left'>环比增减</td>"; break;
        	    	case 3: s = "<tr class='Hbbh'><td align='left'>环比变化(%)</td>"; break;
        	    	case 4: s = "<tr class='Rjcg'><td align='left'>人均持股</td>"; break;
            	}
            	return s ;
            }
        });
    	
    	new DataStore({ //十大流通股东
    		dataType : "json",
            serviceUrl: "/f10/gdjc/sdltgd"
        }).query({
        	obj: currCode,
        	start: -1
        }).then(function(result) {
        	var strArr = [];
        	strArr.push("<tr class='graybg'><td align='left'>股东名称</td><td>持股数(万)</td><td>占流通股比例(%)</td><td>同比变动</td><td>股份性质</td></tr>");
        	$.each(result[currCode][0].data,function(i,item){
				strArr.push("<tr><td align='left'>"+item.gdmc+"</td>");
				strArr.push("<td>"+item.cgs+"</td><td>"+item.zzgs+"%</td>");
				strArr.push("<td>"+(item.zjqk>0?(item.zjqk+"<img src='images/sk_up.gif'>"):item.zjqk)+"</td><td>"+item.gbxz+"</td></tr>");
        	});
			$("#sdltgdDateSpan").html(result[currCode][0].date.substring(0,10));
        	$("#sdltgdBody").html(strArr.join(""));
        });
    	
    	new DataStore({ //十大股东
    		dataType : "json",
            serviceUrl: "/f10/gdjc/sdgd"
        }).query({
        	obj: currCode,
        	start: -1
        }).then(function(result) {
        	var strArr = [];
        	strArr.push("<tr class='graybg'><td align='left'>股东名称</td><td>持股数(万)</td><td>占流通股比例(%)</td><td>同比变动</td><td>股份性质</td></tr>");
        	$.each(result[currCode][0].data,function(i,item){	
				strArr.push("<tr><td align='left'>"+item.gdmc+"</td>");
				strArr.push("<td>"+item.cgs+"</td><td>"+item.zzgs+"%</td>");
				strArr.push("<td>"+(item.zjqk>0?(item.zjqk+"<img src='images/sk_up.gif'>"):item.zjqk)+"</td><td>"+item.gbxz+"</td></tr>");
        	});
        	$("#sdgdDateSpan").html(result[currCode][0].date.substring(0,10));
        	$("#sdgdBody").html(strArr.join(""));
        });
    	
    	new DataStore({ //股本结构
            serviceUrl: "/f10/gbfh/gbjg"
        }).query({
        	obj: currCode,
        	field: "Zgb,Ltag",
        	start: -1,
            count: 1
        }).then(function(result) {
        	var d = result[currCode][0];
        	$("div.two-data-meta").html("流通股总计" + d.Ltag + "万股，占总股份" + Math.round(d.Ltag/d.Zgb*100) + "%");
        	draw(d);
        });
    	
    	function draw(d) {	
    		var result = {
    			"name": "比例",
    			"data": [ ["其他", (d.Zgb-d.Ltag)], ["流通股", d.Ltag] ]
    		};
    		
    		var options = 
    		{
	            chart: {
	                plotBackgroundColor: null,
	                plotBorderWidth: null,
	                plotShadow: false,
	                type: "pie",
	                renderTo: "gbjg"
	            },
	            title: {
	                text: ""
	            },
	            colors: ["#7cb5ec", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#8085e8", "#8d4653", "#91e8e1"],
	            tooltip: {
	                pointFormat: "{series.name}: <b>{point.percentage:.1f}%</b>"
	            },
	            legend: {
	                align: "right",
	                verticalAlign: "middle",
	                borderColor: "#CCC",
	                borderWidth: 1,
	                shadow: false
	            },
	            plotOptions: {
	                pie: {
	                    allowPointSelect: true,
	                    cursor: "pointer",
	                    dataLabels: {
	                        enabled: false
	                    },
	                    showInLegend: true
	                }
	            },
	            series: [result]
	        };
                
            var chart = new Highcharts.Chart(options);
    	}
    	
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
                        
                        <div class="share-capital clearfix">
                            <ul class="tab-style-c">
                                <li class="active"><a href="javascript:void(0);">股本股东</a></li>
                            </ul>
                            
                            <!-- 股本结构 -->
                            <div class="two-data-left">
                                <h3 class="h3-title"><span>股本结构</span></h3>
                                <div class="two-data-content">
                                    <div class="two-data-meta"></div>
                                    <div class="two-data-chart">
                                        <div id="gbjg" style="width:380px;height:200px;"></div>
                                    </div>
                                </div>
                                
                            </div>
                            <!-- 股本结构 -->
                            
                            <!-- 股东户数 -->
                            <div class="two-data-right">
                                <h3 class="h3-title"><span>股东户数</span></h3>
                                <div class="two-data-content">
                                    <table width="100%" class="tablehover table-style-c">
                                        <tbody id="gdhsBody"></tbody>
                                    </table>
                                </div>
                            </div>
                            <!-- 股东户数 -->
                            
                        </div>
                        
                        <div id="gegu_gudong">
                            <ul action="hover" class="tabs tab-style-d">
                                <li class="active"><a href="javascript:void(0)" hidefocus="true">十大流通股东(<span id="sdltgdDateSpan"></span>)</a></li>
                                <li class=""><a href="javascript:void(0)" hidefocus="true">十大股东(<span id="sdgdDateSpan"></span>)</a></li>
                            </ul>
                            <div style="display: block;" class="panel">
                                <table width="100%" class="tablehover table-style-c">
                                    <colgroup>
                                        <col width="40%"><col width="16%"><col width="16%"><col width="14%"><col width="14%">
                                    </colgroup>
                                    <tbody id="sdltgdBody"></tbody>
                                </table>
                            </div>
                            <div class="panel" style="display: none;">
                                <table width="100%" class="tablehover table-style-c">
                                    <colgroup>
                                        <col width="25%"><col width="19%"><col width="24%"><col width="17%"><col width="15%">
                                    </colgroup>
                                    <tbody id="sdgdBody"></tbody>
                                </table>
                            </div>
                        </div>
                        
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