<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>公告中心</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    	$(function(){
    		new DataStore({ //公告中心
                serviceUrl: "/news"
            }).query({
            	type: 3,
            	sort: "DESC",
            	start: -150,
            	count: 150
            }).then(function(result) {
            	if (result) {
            		var temp = [];
                		
               		$.each(result,function(i, r){
                		if (r) {
	                		temp.push("<li title='"+r.title+"' context='"+r.context+"' source='"+r.source+"'><a href='javascript:void(0)'>"+formatTitle(r.title,42)+"</a><span class='time'>"+formatGgTime(r.date,1)+"</span></li>");
                		}
           			});
               		
                	$("#news-list").html(temp.join(""));
                	
    	    		$("#ggPagination").jPages({
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
    	    			var l = $(this).parent("li");
    	    			var address = l.attr("context");
    	    			
    	    			window.open(address);
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
                            <h3 class="h3-title"><span>公告中心</span></h3>
                            <ul id="news-list" class="news-list"></ul>
                        </div>
                        
                        <div id="ggPagination" class="pagination"></div>
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