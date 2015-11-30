<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>行情首页</title>
    <%@include file="head.jsp" %>
    
    <script type="text/javascript">
    
    $(function(){
    	
    	// 增加市场名称的链接
    	(function($){
    		$("h3.scmc").css("cursor","pointer");
    		$("h3.scmc").click(function(){
    			var code = $(this).attr("code");
    			window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + code;
    		});
    	})(jQuery);
    	
    	//市场分时k线
    	(function($){
	    	showImg();
	    	setInterval(function(){
	    		showImg();
	    	}, 10000);
	    	
	    	function showImg() {
	    		var curr = new Date().getTime();
		    	$("#shangzhengImg").attr("src","http://www.stockstar.com/gifchartse/png/000001.png?"+curr);
		    	$("#shenzhengImg").attr("src","http://www.stockstar.com/gifchartse/png/399001.png?"+curr);
		    	$("#hs300Img").attr("src","http://www.stockstar.com/gifchartse/png/000300.png?"+curr);
	    	}
    	})(jQuery);
    	
    	//市场动态行情
    	(function($){
	    	var dynaDataStore = new DataStore({
	            serviceUrl: "/stkdata"
	        });
	    	
	    	var stkCode = ["SH000001","SZ399001","SH000300"];
	    	dynaDataStoreSubscribe(dynaDataStore, stkCode);
	    	
	    	function dynaDataStoreSubscribe(dynaDataStore, stkCode) {
		    	dynaDataStore.subscribe({
					obj: stkCode,
					field: "TJZhangDiePing,ZhongWenJianCheng,ZuiXinJia,ChengJiaoE,ZhangFu,ZhangDie"
				}, {}, function(data) {
					if (data instanceof Error) {
						setTimeout(function(){
							dynaDataStoreSubscribe(dynaDataStore, stkCode);
						}, 3000);
					} else {
						for (x in data) {
							var dynaData = data[x];
							if (dynaData) {	
								valDynaData(dynaData);
							}
						}
					}
				});
	    	}
	    	
	    	function valDynaData(d) {
	    		var t = $("#"+d.Obj);
	    		t.find("h3").html(d.ZhongWenJianCheng).end()
	    		.find(".ZuiXinJia").html(formatNumber(d.ZuiXinJia)).addClass(d.ZhangFu>0?"red":"green").end()
	    		.find(".ZhangDie").html(formatNumber(d.ZhangDie)).end()
	    		.find(".ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).end()
	    		.find(".ChengJiaoE").html(formatNumber(d.ChengJiaoE,null,"Y","亿元")).end()
//	    		.find(".ShangZhangJiaShu").html(d.AGuShangZhangJiaShu).end()
//	    		.find(".PingPanJiaShu").html(d.AGuPingPanJiaShu).end()
//	    		.find(".XiaDieJiaShu").html(d.AGuXiaDieJiaShu).end()
	    		.find("div.stock-realprice").addClass(d.ZhangFu>0?"red":"green").end()
	    		;
	    	}
    	})(jQuery);
    	
    	//涨跌平家数
    	(function($){
    		
    		var zdpDataStore = new DataStore({
	            serviceUrl: "/blockstat"
	        });
    		
    		zdpDataStore.subscribe({
				field: "ZhangDiePing",
				gql: getZdpGql("SH000001")
			}, {}, function(data) {
				valZdp("SH000001", data[0].ZhangDiePing);
			});
    		zdpDataStore.subscribe({
				field: "ZhangDiePing",
				gql: getZdpGql("SZ399001")
			}, {}, function(data) {
				valZdp("SZ399001", data[0].ZhangDiePing);
			});
    		zdpDataStore.subscribe({
				field: "ZhangDiePing",
				gql: getZdpGql("SH000300")
			}, {}, function(data) {
				valZdp("SH000300", data[0].ZhangDiePing);
			});
    		
    		function getZdpGql(sc) {
    			var gql = "";
    			if (sc == "SH000001") {
    				gql = "block=股票\\\\市场分类\\\\上证A股";
    			} else if (sc == "SZ399001") {
    				gql = "block=股票\\\\市场分类\\\\深证A股";
    			} else if (sc == "SH000300") {
    				gql = "block=股票\\\\市场分类\\\\常用指数成份\\\\沪深300";
    			}
    			return gql;
    		}
    		
    		function valZdp(sc,d) {
				$("#"+sc).find(".ShangZhangJiaShu").html(d.ShangZhangJiaShu).end()
				.find(".PingPanJiaShu").html(d.PingPanJiaShu).end()
				.find(".XiaDieJiaShu").html(d.XiaDieJiaShu).end();
    		}
    	})(jQuery);
    	
    	new DataStore({ //公告中心
            serviceUrl: "/news"
        }).query({
        	type: 3,
        	sort: "DESC",
        	start: -6,
        	count: 6
        }).then(function(result) {
        	var temp = [];
        	$.each(result,function(i, r){
        		temp.push("<li context='"+r.context+"' title='"+r.source+"'><a href='javascript:void(0)'>"+formatTitle(r.title,20)+"</a><span class='time'>"+formatGgTime(r.date,2)+"</span></li>");
			});
        	$("#ggul").html(temp.join(""));
    		
    		$("#ggul li a").click(function(){
    			var l = $(this).parent("li");
    			var address = l.attr("context");
    			
    			window.open(address);
    		});
    	});
    	
    	new DataStore({ //新闻中心 
            serviceUrl: "/news"
        }).query({
        	type: 1,
        	sort: "DESC",
        	start: -6,
        	count: 6
        }).then(function(result) {
        	var temp = [];
        	$.each(result,function(i, r){
        		temp.push("<li context='"+r.context+"' source='"+r.source+"' title='"+r.title+"'><a href='javascript:void(0)'>"+formatTitle(r.title,18)+"</a><span class='time'>"+formatNewsTime(r.date,1)+"</span></li>");
			});
        	$("#newsul").html(temp.join(""));
        	
    		$("#newsul li a").click(function(){
    			var l = $(this).parent("li");
    			var address = l.attr("context");
    			var source = l.attr("source");
    			var title = l.attr("title");
    			var time = l.find("span").html();
    			var p = $(".pop-box");
    		
    			// 解析zlib
    			$.get(rootPath+"/RdFileServlet?address="+address,function(data){
    				$(".news-detail-title").html(title);
    				$("div.news-detail-meta").html(time + "	" + "来源：" + source);
    				$("div.news-detail-content").html(data);
    				
	    			p.css({
	    				top: $(document).scrollTop()+50,
	    				left: 200
	    			}).show();
    			});
    		});
    		
    		$("#boxCloseBtn").click(function(){
    			$(".pop-box").hide();
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
                
                <div class="two-columns clearfix">
                    
                    <!-- left-column -->
                    <div class="left-column">
                        
                        <!-- stock-market-index -->
                        <div class="stock-market clearfix">
                            <div id="SH000001">
                                <h3 class="scmc" code="SH000001"></h3>
                                <div class="stock-index ZuiXinJia"><i class="icons"></i></div>
                                <div class="stock-realprice"><span class="ZhangDie"></span><span class="ZhangFu"></span><span class="ChengJiaoE"></span></div>
                                <div class="stock-chart">
                                    <img id="shangzhengImg" src="">
                                </div>
                                <div class="stock-nums">
                                    <div class="red">涨：<span class="ShangZhangJiaShu"></span></div>
                                    <div>平：<span class="PingPanJiaShu"></span></div>
                                    <div class="green">跌：<span class="XiaDieJiaShu"></span></div>
                                </div>
                            </div>
                            <div id="SZ399001">
                                <h3 class="scmc" code="SZ399001"></h3>
                                <div class="stock-index ZuiXinJia"><i class="icons"></i></div>
                                <div class="stock-realprice"><span class="ZhangDie"></span><span class="ZhangFu"></span><span class="ChengJiaoE"></span></div>
                                <div class="stock-chart">
                                    <img id="shenzhengImg" src="">
                                </div>
                                <div class="stock-nums">
                                    <div class="red">涨：<span class="ShangZhangJiaShu"></span></div>
                                    <div>平：<span class="PingPanJiaShu"></span></div>
                                    <div class="green">跌：<span class="XiaDieJiaShu"></span></div>
                                </div>
                            </div>
                            <div id="SH000300">
                                <h3 class="scmc" code="SH000300"></h3>
                                <div class="stock-index ZuiXinJia"><i class="icons"></i></div>
                                <div class="stock-realprice"><span class="ZhangDie"></span><span class="ZhangFu"></span><span class="ChengJiaoE"></span></div>
                                <div class="stock-chart">
                                    <img id="hs300Img" src="">
                                </div>
                                <div class="stock-nums">
                                    <div class="red">涨：<span class="ShangZhangJiaShu"></span></div>
                                    <div>平：<span class="PingPanJiaShu"></span></div>
                                    <div class="green">跌：<span class="XiaDieJiaShu"></span></div>
                                </div>
                            </div>
                        </div>
                        <!-- stock-market-index -->
                        
                        <div class="content-box clearfix">
                            <div class="column-fl">
                                <ul class="tab-style-c">
                                    <li class="active"><a href="javascript:void(0);">新闻中心</a></li>
                                </ul>
                                <div>
                                    <ul id="newsul" class="stock-news"></ul>
                                    <a href="xwzx.jsp" class="news-more">更多&gt;&gt;</a>
                                </div>
                            </div>
                            
                            <div class="column-fr">
                                <ul class="tab-style-c">
                                    <li class="active"><a href="javascript:void(0);">公告中心</a></li>
                                </ul>
                                <div>
                                    <ul id="ggul" class="stock-news"></ul>
                                    <a href="ggzx.jsp" class="news-more">更多&gt;&gt;</a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 板块排行 -->
                        <jsp:include page="bkpaihang.jsp"></jsp:include>
                        
                        <!-- 涨跌幅排行 -->
                        <jsp:include page="zhangdiefupaihang.jsp"></jsp:include>
                        
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
    
    <div class="pop-box" style="display:none;">
        <div class="pop-box-outer">
            <div class="pop-box-inner">
                <div class="news-detail">
                    <h2 class="news-detail-title"></h2>
                    <div class="news-detail-meta"></div>
                    <div class="news-detail-content"></div>
                </div>
            </div>
            <div id="boxCloseBtn" class="pop-box-close"><a href="javascript:void(0);" title="关闭">X</a></div>
        </div>
    </div>
    
</body>
</html>