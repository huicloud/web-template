<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>股票-个股首页</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript" src="js/highstock.js"></script>
    <script type="text/javascript" src="js/chart.js"></script>
    <script type="text/javascript" src="js/chartDataProvider.js"></script>
    <script type="text/javascript">
    $(function(){
    	
    	new DataStore({ //公告中心
    		//dataType: "json",
            serviceUrl: "/news"
        }).query({
        	type: 3,
        	obj: currCode,
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
    		//dataType: "json",
            serviceUrl: "/news"
        }).query({
        	type: 1,
        	obj: currCode,
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
	    				top: $(document).scrollTop()+55,
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
                        <div class="kline-box clearfix">
                            <!-- kline -->
                            <jsp:include page="kline.jsp"></jsp:include>
                            <!-- kline-right wudangpankou-->
                            <jsp:include page="pankou.jsp"></jsp:include>
                        </div>
                        
                        <div class="content-box clearfix">
                            <div class="column-fl">
                                <ul class="tab-style-c">
                                    <li class="active"><a href="javascript:void(0);">公司新闻</a></li>
                                </ul>
                                <div>
                                    <ul id="newsul" class="stock-news"></ul>
                                    <a href="gghq_gsxw.jsp" class="news-more">更多&gt;&gt;</a>
                                </div>
                            </div>
                            
                            <div class="column-fr">
                                <ul class="tab-style-c">
                                    <li class="active"><a href="javascript:void(0);">公司公告</a></li>
                                </ul>
                                <div>
                                    <ul id="ggul" class="stock-news"> </ul>
                                    <a href="gghq_gsgg.jsp" class="news-more">更多&gt;&gt;</a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 公司介绍 -->
                		<jsp:include page="gsjs.jsp"></jsp:include>
                        
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
                
                <!-- 主力资金
                <jsp:include page="zhulizijin.jsp"></jsp:include>
                -->
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