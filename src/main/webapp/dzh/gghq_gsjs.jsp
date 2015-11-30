<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-公司介绍</title>
    <%@include file="head.jsp" %>
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
            </div>
        </div>
    </div>
</body>
</html>