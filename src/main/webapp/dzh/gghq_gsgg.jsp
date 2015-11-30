<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>股票-公司公告</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    	$(function(){
    		
    		new DataStore({ //公司公告
                serviceUrl: "/news"
            }).query({
            	type: 3,
            	obj: currCode, 
            	sort: "DESC",
            	start: -100,
                count: 100
            }).then(function(result) {
            	if (result) {
	            	var temp = [];
	            	$.each(result,function(i, r){
	            		if (r) {
		            		temp.push("<li title='"+r.title+"' context='"+r.context+"' source='"+r.source+"'><a href='javascript:void(0)'>"+formatTitle(r.title,42)+"</a><span class='time'>"+formatGgTime(r.date,1)+"</span></li>");
	            		}
	    			});
	            	$("#news-list").html(temp.join(""));
	            	
		    		$("#gsggPagination").jPages({
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
            
            	<!-- sk-board -->
                <jsp:include page="board.jsp"></jsp:include>

                <div class="two-columns clearfix">
                    
                    <!-- left-column -->
                    <div class="left-column">
                        <div class="news-center clearfix">
                            <h3 class="h3-title"><span>公司公告</span></h3>
                            <ul id="news-list" class="news-list"></ul>
                        </div>
                        <div id="gsggPagination" class="pagination"></div>
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