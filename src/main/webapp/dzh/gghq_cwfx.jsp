<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-财务分析</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript" src="js/highcharts.js"></script>
    <script type="text/javascript">
    $(function(){
    	
    	new DataStore({ //主要财务指标
            serviceUrl: "/f10/cwts/zycwzb"
        }).query({
        	obj: currCode,
        	start: -4,
            count: 4
        }).then(function(result) {
        	var d = $.makeArray(result[currCode]).reverse();
        	
        	var strArr = [];
        	var trArr = ["date","zycwzb","jbmgsy","kchjbmgsy","tbmgsy","mgjzc","mgwfplr","mggjj","xsmll","yylrl","jlrl","jqjzcsyl","tbjzcsyl","gdqy","mgjyxjll","kjssjyj","bbgbr"];
        	
        	for(var i = 0; i < trArr.length; i++) {
        		strArr.push(getZycwzbTablePart(i));
	        	$.each(d,function(j, item){
	        		if (trArr[i] != "zycwzb") {
						strArr.push("<td>" + (trArr[i]=="date" || trArr[i]=="bbgbr" ? item[trArr[i]].substring(0,10) : item[trArr[i]]) + "</td>");
	        		}
	            });
        		strArr.push("</tr>");
        	}
        	
        	$("#zycwzbBody").html(strArr.join(""));
        	
        	function getZycwzbTablePart(i) {
            	var s = "";
            	switch(i){
        	    	case 0: s = "<tr><td align='left'>日期</td>"; break;
        	    	case 1: s = "<tr align='left' class='graybg'><td colspan='5'>主要财务指标</td>"; break;
        	    	case 2: s = "<tr><td align='left'>基本每股收益（元）</td>"; break;
        	    	case 3: s = "<tr><td align='left'>加权每股收益(扣除后)（元）</td>"; break;
        	    	case 4: s = "<tr><td align='left'>摊薄每股收益（元）</td>"; break;
        	    	case 5: s = "<tr><td align='left'>每股净资产（元）</td>"; break;
        	    	case 6: s = "<tr><td align='left'>每股未分配利润(元)</td>"; break;
        	    	case 7: s = "<tr><td align='left'>每股公积金(元)</td>"; break;
        	    	case 8: s = "<tr><td align='left'>销售毛利率(%)</td>"; break;
        	    	case 9: s = "<tr><td align='left'>营业利润率(%)</td>"; break;
        	    	case 10: s = "<tr><td align='left'>销售净利润率(%)</td>"; break;
        	    	case 11: s = "<tr><td align='left'>加权净资产收益率(%)</td>"; break;
        	    	case 12: s = "<tr><td align='left'>摊薄净资产收益率(%)</td>"; break;
        	    	case 13: s = "<tr><td align='left'>股东权益(%)</td>"; break;
        	    	case 14: s = "<tr><td align='left'>每股经营现金流量(元)</td>"; break;
        	    	case 15: s = "<tr><td align='left'>会计师事务所审计意见</td>"; break;
        	    	case 16: s = "<tr><td align='left'>报表公布日</td>"; break;
            	}
            	return s ;
            }
			
        });
    	
    	
    	new DataStore({ //现金流量表
            serviceUrl: "/f10/cwts/xjllbzy"
        }).query({
        	obj: currCode,
        	start: -4,
            count: 4
        }).then(function(result) {
        	var d = $.makeArray(result[currCode]).reverse();
        	
        	var strArr = [];
        	var trArr = ["date","xjllb","jyxjlr","jyxjlc","jyxjje","tzxjlr","tzxjlc","tzxjje","czxjlr","czxjlc","czxjje","xjjzje"];
        	
        	for(var i = 0; i < trArr.length; i++) {
        		strArr.push(getXjllbTablePart(i));
	        	$.each(d,function(j, item){
	        		if (trArr[i] != "xjllb") {
						strArr.push("<td>" + (trArr[i]=="date" ? item[trArr[i]].substring(0,10) : (item[trArr[i]]/10000).toFixed(2)) + "</td>");
	        		}
	            });
        		strArr.push("</tr>");
        	}
        	
        	$("#xjllbBody").html(strArr.join(""));
        	
        	function getXjllbTablePart(i) {
            	var s = "";
            	switch(i){
        	    	case 0: s = "<tr><td align='left'>日期</td>"; break;
        	    	case 1: s = "<tr align='left' class='graybg'><td colspan='5'>现金流量表 单位(万元)</td>"; break;
        	    	case 2: s = "<tr><td align='left'>经营现金流入小计</td>"; break;
        	    	case 3: s = "<tr><td align='left'>经营现金流出小计</td>"; break;
        	    	case 4: s = "<tr><td align='left'>经营现金流量净额</td>"; break;
        	    	case 5: s = "<tr><td align='left'>投资现金流入小计</td>"; break;
        	    	case 6: s = "<tr><td align='left'>投资现金流出小计</td>"; break;
        	    	case 7: s = "<tr><td align='left'>投资现金流量净额</td>"; break;
        	    	case 8: s = "<tr><td align='left'>筹资现金流入小计</td>"; break;
        	    	case 9: s = "<tr><td align='left'>筹资现金流出小计</td>"; break;
        	    	case 10: s = "<tr><td align='left'>筹资现金流量净额</td>"; break;
        	    	case 11: s = "<tr><td align='left'>现金等的净增加额</td>"; break;
            	}
            	return s ;
            }
			
        });
    	
    	
    	new DataStore({ //单季度利润(收入趋势)
            serviceUrl: "/f10/zxjb/djdleb"
        }).query({
        	obj: currCode,
        	start: -4,
            count: 4
        }).then(function(result) {
        	var d = result[currCode][3];
        	$("div.two-data-left .h3-title").html("收入趋势（"+d.date.substring(0,10)+"）");
        	$("div.two-data-left .two-data-meta").html("实现净利润"+d.jlr+"万元，实现主营收入"+d.yysr+"万元");
        	drawSrqs(result[currCode]);
        	
	    	function drawSrqs(d) {
	    		
	    		var timeArr = [], jlrArr = [], yysrArr = [];
				$.each(d,function(i, item){
	    			timeArr.push(item.date.substring(0,10));
	    			jlrArr.push(item.jlr);
	    			yysrArr.push(item.yysr);
    			});
	    		
	    		var result = {
    			    "time": timeArr,
    			    "data":[
    			        {
    			            "name": "净利润",
    			            "data": jlrArr
    			        },
    			        {
    			            "name": "主营收入",
    			            "data": yysrArr
    			        }
    			    ]
    			}
	    		
	    		var options = 
	    		{
	                chart: {
	                    renderTo: $("#srqs").get(0),
	                    type: "line"
	                },
	                title: {
	                    text: "",
	                    x: -20 //center
	                },
	                subtitle: {
	                    text: "",
	                    x: -20
	                },
	                colors: ["#7cb5ec", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#8085e8", "#8d4653", "#91e8e1"],
	                xAxis: {
	                    categories: result.time,
	                    gridLineWidth: 1
	                },
	                yAxis: {
	                    title: {
	                        text: null
	                    },
	                    labels: {
	                        format: "{value}"
	                    },
	                    plotLines: [{
	                        value: 0,
	                        width: 1,
	                        color: "#808080"
	                    }],
	                },
	                tooltip: {
	                    valueSuffix: ""
	                },
	
	                series: result.data
	            };
	            
	            var chart = new Highcharts.Chart(options);
	            
	    	}
	    	
        });
    	
    	
    	new DataStore({ //单季财务指标(收益趋势)
            serviceUrl: "/f10/zxjb/djdcwzb"
        }).query({
        	obj: currCode,
        	start: -4,
            count: 4
        }).then(function(result) {
        	var d = result[currCode][3];
        	$("div.two-data-right .h3-title").html("收益趋势（"+d.date.substring(0,10)+"）");
        	$("div.two-data-right .two-data-meta").html("基本每股收益"+d.mgsy+"元");
        	drawSyqs(result[currCode]);
        	
	    	function drawSyqs(d) {
	    		var timeArr = [], jlrArr = [];
				$.each(d,function(i, item){
	    			timeArr.push(item.date.substring(0,10));
	    			jlrArr.push(item.mgsy);
    			});
	    		
	    		var result = {
    			    "time": timeArr,
    			    "data":[
    			        {
    			            "name": "基本每股收益",
    			            "data": jlrArr
    			        }
    			    ]
    			}
	    		
	    		var options = 
	    		{
                    chart: {
                        renderTo: $("#syqs").get(0),
                        type: "column"
                    },
                    title: {
                        text: "",
                        x: -20 //center
                    },
                    subtitle: {
                        text: "",
                        x: -20
                    },
                    colors: ["#7cb5ec", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#8085e8", "#8d4653", "#91e8e1"],
                    xAxis: {
                        categories: result.time,
                        gridLineWidth: 1
                    },
                    yAxis: {
                        title: {
                            text: null
                        },
                        labels: {
                            format: "{value:.1f}"
                        },
                        plotLines: [{
                            color: "#808080"
                        }]
                    },
                    tooltip: {
                        valueSuffix: ""
                    },
                    series: result.data
                };
                
                var chart = new Highcharts.Chart(options);
	    	}
	    	
        });
    	
    	
    });
    </script>
</head>
<body>
    <div class="wrapper">
        <div class="site-header">
            <!-- 导航栏 -->
            <jsp:include page="navigation.jsp"></jsp:include>
        </div>
        
        <div class="site-content">
            <div class="container">
                
                <!-- sk-board -->
                <jsp:include page="board.jsp"></jsp:include>
                
                <div class="two-columns clearfix">
                    
                    <!-- left-column -->
                    <div class="left-column">
                        
                        <!-- 财务数据 -->
                        <div class="finance-data clearfix">
                            <ul class="tab-style-c">
                                <li class="active"><a href="javascript:void(0);">财务数据</a></li>
                            </ul>
                            
                            <!-- 收入趋势 -->
                            <div class="two-data-left">
                                <h3 class="h3-title"></h3>
                                <div class="two-data-content">
                                    <div class="two-data-meta"></div>
                                    <div class="two-data-chart">
                                        <div id="srqs" style="width:380px;height:250px;"></div>
                                    </div>
                                </div>
                                
                            </div>
                            <!-- 收入趋势 -->
                            
                            
                            <!-- 收益趋势 -->
                            <div class="two-data-right">
                                <h3 class="h3-title"></h3>
                                <div class="two-data-content">
                                    <div class="two-data-meta"></div>
                                    <div class="two-data-chart">
                                        <div id="syqs" style="width:380px;height:250px;"></div>
                                    </div>
                                </div>
                                
                            </div>
                            <!-- 收益趋势 -->
                            
                        </div>
                        <!-- 财务数据 -->
                        
                        
                        <!-- 财务摘要 -->
                        <div class="finance-data clearfix">
                            <ul class="tab-style-c">
                                <li class="active"><a href="javascript:void(0);">财务摘要</a></li>
                            </ul>
                            <!-- 主要财务指标 -->
                            <div class="mb15">
	                            <table width="100%" class="tablehover table-style-c">
	                                 <colgroup><col width="26%"><col width="18%"><col width="18%"><col width="18%"><col width=""></colgroup>
	                                 <tbody id="zycwzbBody"></tbody>
	                            </table>
                            </div>
                            <!-- 现金流量表 -->    
                            <div>
                                <table width="100%" class="tablehover table-style-c">
                                    <colgroup><col width="26%"><col width="18%"><col width="18%"><col width="18%"><col width=""></colgroup>
                                    <tbody id="xjllbBody"></tbody>
                                </table>
                            </div>
                        </div>
                        <!-- 财务摘要 -->
                        
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