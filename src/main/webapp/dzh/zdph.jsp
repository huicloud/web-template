<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>涨跌排行</title>
    <%@include file="head.jsp" %>
    <script type="text/javascript">
    $(function(){
    	
    	//填充body
    	(function($){
    		valBody($("#zdfBody"));
    		function valBody(tbody) {
    			var temp = [];
        		tbody.empty();
        		for(var i=0; i<100; i++) {
        			temp.push("<tr><td class='Obj'></td>");
        			temp.push("<td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td>");
        			temp.push("<td class='ZhangDie'></td><td class='ZhangFu'></td>");
        			temp.push("<td class='ZuoShou'></td><td class='KaiPanJia'></td>");
        			temp.push("<td class='ZuiGaoJia'></td><td class='ZuiDiJia'></td>");
        			temp.push("<td class='ChengJiaoLiang'></td><td class='HuanShou'></td></tr>");
        		}
        		tbody.html(temp.join(""));
    		}
    	})(jQuery);
    	
	    var sortDataStore = new DataStore({ //涨跌幅排行数据源
			serviceUrl: "/sort/range",
			otherParams: { start: 0, count: 100 }
		});
	    var dynaDataStore = new DataStore({ //动态行情数据源
	        serviceUrl: "/stkdata"
	    });
	    
    	var intervalID, shichang, sort;
    	$("#shichangul li").click(function(){
    		$(this).addClass("active").siblings().removeClass("active");
    		shichang = $(this).attr("sc");
    		$("span.sort").removeClass("sort_desc");
	    	$("span.sort").trigger("click");
    	});
    	$("span.sort").click(function(){
			if ($(this).hasClass("sort_desc")) {
				sort = "sort_desc";
				$(this).removeClass("sort_desc").addClass("sort_asc");
			} else {
				sort = "sort_asc"
				$(this).removeClass("sort_asc").addClass("sort_desc");
			}
			valZhangDieFu(shichang, sort);
//			if(intervalID) clearInterval(intervalID);
//			intervalID = setInterval(function(){valZhangDieFu(shichang, sort);}, 10000);
		});
    	$("#shichangul li:eq(0)").trigger("click");
    	
    	function valZhangDieFu(shichang, sort) {
    		sortDataStore.cancel();
    		sortDataStore.subscribe({
    			desc: (sort=="sort_asc") ? true : false,
    			field: "ZhangFu",
    			gql: getZdfGql(shichang)
    		}).then(function(data){
    			valStocks($("#zdfBody"), data);
				pageStock();
    		});
    	}
    	
    	function getZdfGql(sc) {
    		var gql = "";
    		if (sc == "hushenagu") {
    			gql = "block=股票\\\\市场分类\\\\上证A股 or block=股票\\\\市场分类\\\\深证A股";
    		} else if (sc == "zhongxiaoban") {
    			gql = "block=股票\\\\市场分类\\\\中小企业板";
    		} else if (sc == "chuangyeban") {
    			gql = "block=股票\\\\市场分类\\\\创业板";
    		}
    		return gql;
    	}
    	
    	function valStocks(tbody, data) {
    		var tr,count = 0;
    		$.each(data,function(i, item){
    			tr = tbody.find("tr:eq("+(count++)+")");
				tr.attr("class", "zdf_"+item.Obj);
				tr.attr("code",item.Obj);
				tr.find(".Obj").html(item.Obj).end()
				.find(".ZhongWenJianCheng").css("cursor","pointer")
				.bind("mouseenter",function(){
    				$(this).addClass("blue");
    			}).bind("mouseleave",function(){
    				$(this).removeClass("blue");
    			}).end()
    			.find(".ZuiXinJia").removeClass("red green").end()
    			.find(".ZhangDie").removeClass("red green").end()
    			.find(".ZhangFu").removeClass("red green").end()
    			;
			});
    	}
    	
    	function pageStock() {
			//$("#zdfTable").stupidtable();
			$("#zdfPagination").jPages({
    			containerID : "zdfBody",
    			first : "首页",
    			last : "尾页",
    			previous : "上一页",
    			next : "下一页",
    			perPage : 20,
    			delay : 0,
    			animation: "wobble",
    			callback: function (pages, items) {
    				/*
    				if(intervalID) clearInterval(intervalID);
    				intervalID = setInterval(function(){valZhangDieFu(shichang, sort);}, 10000);
    				*/
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
    			field: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ZuoShou,KaiPanJia,ZuiGaoJia,ZuiDiJia,ChengJiaoLiang,HuanShou"
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
    			var tr = $("tr.zdf_"+d.Obj);
    			tr.find(".Obj").html(d.Obj).end()
    			.find(".ZhongWenJianCheng").html(d.ZhongWenJianCheng).bind("click",function(){
    				window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + d.Obj;
    			}).end()
    			.find(".ZuiXinJia").html(formatNumber(d.ZuiXinJia)).addClass((d.ZhangFu>0)?"red":"green").end()
    			.find(".ZhangDie").html(formatNumber(d.ZhangDie)).addClass((d.ZhangFu>0)?"red":"green").end()
    			.find(".ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass((d.ZhangFu>0)?"red":"green").end()
    			.find(".ZuoShou").html(formatNumber(d.ZuoShou)).end()
    			.find(".KaiPanJia").html(formatNumber(d.KaiPanJia)).end()
    			.find(".ZuiGaoJia").html(formatNumber(d.ZuiGaoJia)).end()
    			.find(".ZuiDiJia").html(formatNumber(d.ZuiDiJia)).end()
    			.find(".ChengJiaoLiang").html(formatNumber(d.ChengJiaoLiang,0)).end()
    			.find(".HuanShou").html(formatNumber(d.HuanShou)).end()
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
                        
                        <!-- 涨跌排行 -->
                        <div class="finance-data clearfix">
                            <ul id="shichangul" class="tab-style-c">
                                <li sc="hushenagu" class="active"><a href="javascript:void(0);">A股</a></li>
                                <li sc="zhongxiaoban"><a href="javascript:void(0);">中小板</a></li>
                                <li sc="chuangyeban"><a href="javascript:void(0);">创业板</a></li>
                            </ul>
                            
                            <div class="panel mb15" style="display:block">
                                <table id="zdfTable" width="100%" class="display table-style-a table-sort">
                                    <col width=""><col width=""><col width=""><col width=""><col width="">
                                    <thead>
	                                    <tr>
	                                    	<th>代码</th>
	                                    	<th>名称</th>
	                                    	<th>最新价</th>
	                                    	<th>涨跌额</th>
	                                    	<th><span class="sort sort_asc">涨跌幅</span></th>
	                                    	<th>昨收</th>
	                                    	<th>今开</th>
	                                    	<th>最高</th>
	                                    	<th>最低</th>
	                                    	<th>成交量</th>
	                                    	<th>换手率</th>
	                                    </tr>
                                    </thead>
                                    <tbody id="zdfBody"></tbody>
                                </table>
                                <div id="zdfPagination" class="pagination"></div>
                            </div>
                        </div>
                        <!-- 涨跌排行 -->
                        
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