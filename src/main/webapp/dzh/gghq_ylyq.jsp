<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-盈利预期</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript" src="js/highcharts.js"></script>
    <script type="text/javascript">
    $(function(){
    	
    	new DataStore({ //业绩预测
    		//dataType: "json",
    	    serviceUrl: "/forecasts/yzxyjyc"
    	}).query({
    		obj: currCode,
    	    type: 1
    	}).then(function(result) {
    		var data = result[currCode];
    		drawYjyc(data);
    		
    		function drawYjyc(d) {
    			var timeArr = [], jlrArr = [], mgsyArr = [];
				$.each(d,function(i, item){
        			timeArr.push(item.yuCeNianDu.substring(0,4));
        			jlrArr.push((item.jingLiRun/10000));
        			mgsyArr.push(item.meiGuShouYi);
    			});
		
    			var result = {
   				    "time": timeArr,
   				    "data": [
   				        {
   				            "name": "净利润",
   				            "type": "column",
   				            "data": jlrArr
   				        },
   				        {
   				            "name": "每股收益",
   				            "type": "line",
   				            "yAxis": 1,
   				            "data": mgsyArr
   				        }
   				    ]
   				};
    			
    			var options = {
   	                chart: {
   	                    zoomType: "xy",
   	                    renderTo: "yjyc"
   	                },
   	                title: {
   	                    text: ""
   	                },
   	                subtitle: {
   	                    text: ""
   	                },
   	                colors: ["#7cb5ec", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#8085e8", "#8d4653", "#91e8e1"],
   	                xAxis: [{
   	                    categories: result.time,
   	                    crosshair: true
   	                }],
   	                yAxis: [{ // Primary yAxis
   	                    labels: {
   	                        format: "{value:.2f}"
   	                    },
   	                    title: {
   	                        text: "净利润(万元)"
   	                    }
   	                }, { // Secondary yAxis
   	                    title: {
   	                        text: "每股收益(元)"
   	                    },
   	                    labels: {
   	                        format: "{value:.2f}"
   	                    },
   	                    opposite: true
   	                    
   	                }],
   	                tooltip: {
   	                    shared: true
   	                },
   	                plotOptions: {
   	                    series: {
   	                        borderWidth: 0,
   	                        dataLabels: {
   	                            enabled: true,
   	                            format: "{point.y:.2f}"
   	                        }
   	                    }
   	                },
   	                legend: {
   	                    align: "center",
   	                    verticalAlign: "bottom"

   	                },
   	                series: result.data
   	            };
   	                
   	            var chart = new Highcharts.Chart(options);
    		}
    	});
    	
    	
    	new DataStore({ //投资评级
    		//dataType: "json",
    	    serviceUrl: "/forecasts/yzxtzpj"
    	}).query({
    		obj: currCode
    	}).then(function(result) {
    		var data = result[currCode];
    		var pre = data[0].zhengTiPinJi;
    		var curr = data[1].zhengTiPinJi;
    		
    		$("#tzpjDiv").addClass("iqktop" + getPinJiNum(curr));
    		$("#tzpjnextDiv").addClass("iqknnder" + getPinJiNum(pre));
    	});
    	
    	var c = new Date().getFullYear();
    	$("#curryear").html(c+"EPS");
    	$("#nextyear").html((c+1)+"EPS");
    	new DataStore({ //投资评级及预期
    		//dataType: "json",
    	    serviceUrl: "/forecasts/ggyjyc"
    	}).query({
    		obj: currCode
    	}).then(function(result) {
    		var d = result[currCode].data;
    		var arr = [];
    		$.each(d,function(i, r){
    			var m = "", n = ""; //m本年度和n下年度的预期每股收益
				$.each(r.data,function(i, p){
    				var t = p.yuCeNianDu.substring(0,4);
    				if (t == c) m = p.meiGuShouYi;
    				if (t == c+1) n = p.meiGuShouYi;
    			});
    			
    			arr.push("<tr align='center'><td height='30'>"+r.yanJiuJiGou+"</td>");
    			arr.push("<td class='f11'><span class='FC3'>"+r.baoGaoRiQi.substring(0,8)+"</span></td>");
    			arr.push("<td class='f11'><span class='FC1'>"+m+"</span></td>");
    			arr.push("<td class='f11'><span class='FC1'>"+n+"</span></td></tr>");
			});
    		
    		$("#listforecast").html(arr.join(""));
    	});
    	
    	
    	new DataStore({ //个股投资研报
    		dataType: "json",
    	    serviceUrl: "/forecasts/ggtzyb"
    	}).query({
    		obj: currCode
    	}).then(function(result) {
    		var d = result[currCode];
    		var arr = [];
    		$.each(d,function(i, r){
    			arr.push("<tr><td class='f11'>"+formatGgTime(r.baoGaoRiQi.substring(0,8),1)+"</td>");
    			arr.push("<td>"+r.pinJiLeiBie+"</td><td>"+r.pinJiBianDong+"</td><td>"+r.yanJiuJiGou+"</td>");
    			arr.push("<td class='tal'><a link='"+r.yanBaoNeiRong+"' href='javascript:void(0)'>"+r.yanBaoBiaoTi+"</a></td></tr>");
			});
    		$("#tzybBody").html(arr.join(""));
    		
    		$("#tzybBody tr a").click(function(){
    			var address = $(this).attr("link");
    			window.open(address);
    		});
    	});
    	
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
                        
                        <div class="profit-expected clearfix">
                            
                            <%--
                            <div class="jycl">
                                <h3 class="h3-title"><span>交易策略</span></h3>
                                
                                <div class="jycl-content">
                                    <h5 class="f14b">走势特征及操作建议：</h5>
                                    <p> 中期走势向上，短期走势向下。 短线走弱，观望。</p>
                                    <h5 class="f14b">主力控盘分析：</h5>
                                    <p> 大智慧散户数评估模型显示，散户数评测值为630132，人均持股评测值为236.82手，大资金持股估计占流通股本的69.97%，和60日前相比降低了0.00个百分点；筹码高度集中的庄股，可以跟庄，但要注意控制风险；最近10日，散户数评测值增加425，显示主力近期仓位变化不明显</p>
                                    <h5 class="f14b">移动筹码分析：</h5>
                                    <p> 昨日收盘价比市场平均成本低0.92%。筹码密集区内，注意突破方向。</p>
                                    <h5 class="f14b">成交笔数分析：</h5>
                                    <p> 近日平均每笔成交手数减小，大资金操作力度减弱。</p>
                                    <h5 class="f14b">投资价值分析：</h5>
                                    <p> 账面价值/市场价值=0.9823，投资价值极高。 </p>
                                </div>
                            </div>
                             --%>
                            
                            <div class="yjyc">
                                <h3 class="h3-title"><span>业绩预测</span></h3>
                                <%--
                                <div class="yjyc-txt">截至2015-05-26，近四个月共有21家机构对该股作出2015年度业绩预测，机构一致性预测净利润为4985485.59万元，每股收益为2.68元（最高3.06元，最低2.36元）。</div>
                                 --%>
                                <div class="yjyc-content">
                                    <div id="yjyc" style="width:600px;height:300px;"></div>
                                </div>
                            </div>
                            
                            <div class="tzpj">
                                <h3 class="h3-title"><span>投资评级</span></h3>
                                
                                <div class="tzpj-chart">
                                    
                                    <div class="situation">
                                        <div class="iqktop">
                                            <div id="tzpjDiv">
                                                <div class="up-pos">
                                                    <div class="up-bg"><span>本期评级</span></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="iqknnder">
                                            <div id="tzpjnextDiv">
                                                <div class="up-pos">
                                                    <div class="up-bg"><span>上一期评级</span></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="tzpj-content">
                                    
                                    <table width="100%" class="table-style-e">
                                        <thead>
                                            <tr>
                                              <th>研究机构</th>
                                              <th>评级日期</th>
                                              <th id="curryear"></th>
                                              <th id="nextyear"></th>
                                            </tr>
                                        </thead>
                                        <tbody id="listforecast"></tbody>
                                    </table>
                                    
                                    <table width="100%" class="table-style-e mt10">
                                        <thead>
                                            <tr>
                                                <th width="10%">报告日期</th>
                                                <th width="10%">评级类别</th>
                                                <th width="10%">评级变动</th>
                                                <th width="10%">机构名称</th>
                                                <th>研报</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tzybBody"></tbody>
                                    </table>
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- left-column -->
                    
                    
                    <!-- right-column -->
                    <div class="right-column">
                        <!-- 我的自选 -->
                        <jsp:include page="common_mystocks.jsp"></jsp:include>
                    </div>
                    <!-- right-column -->
                    
                </div>
            </div>
        </div>
    </div>
</body>
</html>