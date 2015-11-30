<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>板块概念</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    $(function(){
    	var bkDataStore = new DataStore({ //板块排行
    		serviceUrl: "/sort/range",
    		fields: "ZhangFu",
    		otherParams: { start: 0, count: 100 }
    	});
    	var dynaDataStore = new DataStore({ //动态行情数据源
            serviceUrl: "/stkdata"
        });
    	
		$("span.sort").click(function(){
			if ($(this).hasClass("sort_desc")) {
				sort = "sort_desc";
				$(this).removeClass("sort_desc").addClass("sort_asc");
			} else {
				sort = "sort_asc"
				$(this).removeClass("sort_asc").addClass("sort_desc");
			}
			valZhangDieFu(sort);
		});
		$("span.sort").trigger("click");
    	
    	function valZhangDieFu(sort) {
    		dynaDataStore.cancel();
    		bkDataStore.cancel();
    		bkDataStore.query({
    			desc: (sort=="sort_desc") ? true : false,
    			market: "B$"
    		}).then(function(data){
    			valBkBody($("#bkBody"), data);
				pageBk();
    		});
    	}
    	
    	function valBkBody(bkBody, data) {
    		var temp = [];
    		bkBody.empty();
    		var count = 0;
    		$.each(data,function(i, item){
    			temp.push("<tr class='bk_" + item.Obj.substr(2) + "' code='" + item.Obj + "'><td>"+(++count)+"</td>");
    			temp.push("<td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td><td class='ZhangFu'></td>");
    			temp.push("<td class='ChengJiaoE'></td><td class='ZuoShou'></td><td class='KaiPanJia'></td></tr>");
    		});
    		bkBody.html(temp.join(""));
    	}
    	
    	function pageBk() {
			//$("#bkTable").stupidtable();
			$("#bkgnPagination").jPages({
    			containerID : "bkBody",
    			first : "首页",
    			last : "尾页",
    			previous : "上一页",
    			next : "下一页",
    			perPage : 20,
    			delay : 10,
    			animation: "wobble",
    			callback: function (pages, items) {
    				var s = items.showing;
    				var stkCode = [];
    				$.each(s, function(i,item){
	    				stkCode.push(item.getAttribute("code"));
    				});
 				
					dynaDataStore.cancel();
					dynaDataStoreSubscribe(dynaDataStore, stkCode);
    			}
    		});
		}
    	
    	function dynaDataStoreSubscribe(dynaDataStore, stkCode) {
    		dynaDataStore.subscribe({
    			obj: stkCode,
    			field: "ZhongWenJianCheng,ZhangFu,ZongShiZhi,HuanShou,ChengJiaoE,ZuiXinJia,ZuoShou,KaiPanJia"
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
    		
    		function valDynaData(d) {
    			var tr = $("tr.bk_"+d.Obj.substr(2));	
    			tr.find("td.ZhongWenJianCheng").html(d.ZhongWenJianCheng).end()
    			.find("td.ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end()
    			.find("td.ChengJiaoE").html(formatNumber(d.ChengJiaoE,null,"Y")).end()
    			.find("td.ZuiXinJia").html(formatNumber(d.ZuiXinJia)).addClass(d.ZhangFu>0?"red":"green").end()
    			.find("td.ZuoShou").html(formatNumber(d.ZuoShou)).end()
    			.find("td.KaiPanJia").html(formatNumber(d.KaiPanJia)).end()
    			;
    		}
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
                <div class="two-columns clearfix">
                    
                    <!-- left-column -->
                    <div class="left-column">
                        
                        <div class="finance-data clearfix">
                            <div class="mb15">
                                <table id="bkTable" width="100%" class="table-style-a">
                                    <col width=""><col width=""><col width=""><col width=""><col width="">
                                    <thead>
	                                    <tr>
	                                    	<th>排名</th>
	                                    	<th>板块名称</th>
	                                    	<th>最新价</th>
	                                    	<th><span class="sort sort_desc">涨跌幅</span></th>
	                                    	<th>成交额（亿）</th>
	                                    	<th>昨收</th>
	                                    	<th>今开</th>
	                                    </tr>
                                    </thead>
                                    <tbody id="bkBody"></tbody>
                                </table>
                                <div id="bkgnPagination" class="pagination"></div>
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