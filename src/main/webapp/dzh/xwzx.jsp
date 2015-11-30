<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>新闻中心</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    	$(function(){
    		
    		new DataStore({ //新闻中心 
                serviceUrl: "/news"
            }).query({
            	type: 1,
            	sort: "DESC",
            	start: -150,
            	count: 150
            }).then(function(result) {	
            	if (result) {
            		var temp = [];
                	$.each(result,function(i, r){
                		if (r) {
	                		temp.push("<li title='"+r.title+"' context='"+r.context+"' source='"+r.source+"'><a href='javascript:void(0)'>"+formatTitle(r.title,42)+"</a><span class='time'>"+formatNewsTime(r.date,1)+"</span></li>");
                		}
                		
                	});
                	$("#news-list").html(temp.join(""));
                	
    	    		$("#xwPagination").jPages({
    	    			containerID : "news-list",
    	    			first : "首页",
    	    			last : "尾页",
    	    			previous : "上一页",
    	    			next : "下一页",
    	    			perPage : 20,
    	    			delay : 5,
    	    			animation: "wobble"
    	    		});
    	    		
    	    		$("#news-list li a").click(function(){
    	    			// http://rdfile.gw.com.cn/DID/NEWS/2E/2F/2E2F8F4A001A288A56553D4D04B1AA9E.txt.zlib
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
            	}
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
                        
                        <div class="news-center clearfix">
                            <h3 class="h3-title"><span>新闻中心</span></h3>
                            <ul id="news-list" class="news-list"></ul>
                        </div>
                        
                        <div id="xwPagination" class="pagination"></div>
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
        
    </div>
</body>
</html>