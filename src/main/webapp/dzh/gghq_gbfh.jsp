<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>个股行情-股本分红</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    $(function(){
    	
    	new DataStore({ //历史分配记录
            serviceUrl: "/f10/gbfh/fhkg"
        }).query({
        	obj: currCode,
        	start: -15,
            count: 15
        }).then(function(result) {   	
			var d = $.makeArray(result[currCode]).reverse();
        	var strArr = [];
        	var trArr = ["Date","Mgsg","Mgzz","Mgfh","Mgp","Pgjg","Zfgfsl","Zfjg","Gqdjr","Cqcxr"];
        	
        	$.each(d,function(j, item){	
       			strArr.push("<tr>");
	        	for (var i = 0; i < trArr.length; i++) {
	        		var r = item[trArr[i]];
	        		if (r==0 || r==""){
	        			r = "--";
	        		}
		        	strArr.push("<td>"+(r.toString().indexOf("00:00:00")>0?r.substring(0,10):r)+"</td>");
	        	}
       			strArr.push("</tr>");
            });
        	
        	$("#fhkgBody").html(strArr.join(""));
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
                        
                        <div class="capital-bonus clearfix">
                            
                            <ul class="tab-style-c">
                                <li class="active"><a href="javascript:void(0);">历史分配记录</a></li>
                            </ul>
                            <div>
                                <table width="100%" class=" table-style-e">
                                    <thead>
                                        <tr>
                                            <th>时间</th>
                                            <th>送股</th>
                                            <th>转增</th>
                                            <th>分红(元/税前)</th>
                                            <th>配股</th>
                                            <th>配股价格(元)</th>
                                            <th>增发(万股)</th>
                                            <th>增发价格</th>
                                            <th>股权登记日</th>
                                            <th>除权除息日</th>
                                        </tr>
                                    </thead>
                                    <tbody id="fhkgBody"></tbody>
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