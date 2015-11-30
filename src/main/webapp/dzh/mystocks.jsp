<%@ page language="java" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="zh-CN" class="no-js">
<head>
    <title>我的自选股</title>
    <%@include file="head.jsp" %>
	<script type="text/javascript">
	$(function(){
		var myCode = [], resultCode = 1;
		//动态行情数据源 专门处理 自选股
		var mystockDynaDataStore = new DataStore({
		    serviceUrl: "/stkdata"
		});
		
		//查询出所有自选股
		$.ajax({
			type: "get",
			url: mystockurl+"/myStock.do",
			dataType: "jsonp",
			jsonpCallback: "jsonpCallback",
			success: function(result) {
				// Object { resultMsg="自选股查询成功",  data=[2],  resultCode=0}
				resultCode = result.resultCode;
				if (result.resultCode == 0) {
					var arr = result.data;
					$.each(arr,function(i, item){
						myCode.push(item.STOCKCODE);
	    			});
				}
			},
			complete: function() {
				if (resultCode == 0 && myCode.length>0) {
					var arr = [];
					$.each(myCode,function(i, item){
						arr.push("<tr id='mystock_"+item+"' code='"+item+"'>");
						arr.push("<td class='obj'>"+item+"</td><td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td><td class='ZhangDie'></td>");
						arr.push("<td class='ZhangFu'></td><td class='ZuoShou'></td><td class='KaiPanJia'></td>");
						arr.push("<td class='ZuiGaoJia'></td><td class='ZuiDiJia'></td><td class='ChengJiaoLiang'></td>");
						arr.push("<td class='HuanShou'></td><td class='no-pd'><a href='javascript:void(0)' class='del-stock-btn hide'></a></td></tr>");
	    			});
					
					$("#mystockBody").html(arr.join(""));
					
					editStock();
					pageMystock();
				}
			}
		});
		
		function editStock() {
			//添加删除自选股
			$(".del-stock-btn,.add-stock-btn").each(function(){
			    $(this).parents("tr").hover(
			        function(){
			            $(this).find(".del-stock-btn,.add-stock-btn").removeClass("hide");
			        },
			        function(){
			            $(this).find(".del-stock-btn,.add-stock-btn").addClass("hide");
			    })
			});
			
			$(".del-stock-btn").click(function(){
				var tr = $(this).parents("tr");
				$.ajax({
					type: "get",
					url: mystockurl+"/delStock.do",
					data: {code: tr.find(".obj").html()},
					dataType: "jsonp",
					jsonpCallback: "jsonpCallback",
					success: function(data) {
						//  Object { resultMsg="自选股删除成功",  resultCode=0}
						if(data.resultCode == 0) {
							tr.remove();
							//从myCode中删除
							//var index = $.inArray(tr.find(".obj").html(), myCode);
							//myCode.splice(index, 1);
							
						}
					}
				});
			});
		}
		
		function pageMystock() {
			$("#mystockTable").stupidtable();
			$("div.pagination").jPages({
    			containerID : "mystockBody",
    			first : "首页",
    			last : "尾页",
    			previous : "上一页",
    			next : "下一页",
    			perPage : 10,
    			delay : 10,
    			animation: "wobble",
    			callback: function (pages, items) {
    				var s = items.showing;
    				var stkCode = [];
    				$.each(s, function(i,item){
	    				stkCode.push(item.getAttribute("code"));
    				});
 				
    				mystockDynaDataStore.cancel();
					mystockDynaDataStoreSubscribe(mystockDynaDataStore, stkCode);
    			}
    		});
		}
		
		function mystockDynaDataStoreSubscribe(dynaDataStore, stkCode) {
			dynaDataStore.subscribe({
				obj: stkCode,
				field: "ZhongWenJianCheng,ZuiXinJia,ZhangDie,ZhangFu,ZuoShou,KaiPanJia,ZuiGaoJia,ZuiDiJia,ChengJiaoLiang,HuanShou,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1"
			}, {}, function(data) {
				if (data instanceof Error) {
					setTimeout(function(){
						mystockDynaDataStoreSubscribe(dynaDataStore, stkCode);
					}, 3000);
				} else {
					for (x in data) {
						var dynaData = data[x];
						if (dynaData) {	
							valMyStockDynaData(dynaData);
						}
					}
				}
			});
		}   

		//根据推送的动态行情数据填充响应的元素
		function valMyStockDynaData(d) {
			var mystock_stk = $("#mystock_"+d.Obj);
			//处理自选
			if (mystock_stk.length>0) {
				mystock_stk.find(".obj").html(d.Obj).end()
				.find(".ZhongWenJianCheng").html(d.ZhongWenJianCheng).css("cursor","pointer")
				.bind("mouseenter",function(){
    				$(this).addClass("blue");
    			}).bind("mouseleave",function(){
    				$(this).removeClass("blue");
    			}).bind("click",function(){
    				window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + d.Obj;
    			});
				
				// 如果最新价是NaN，做停牌处理
				var flag = isTingPai(d.ZuiXinJia, d.WeiTuoMaiRuJia1, d.WeiTuoMaiChuJia1);
				mystock_stk.find(".ZuiXinJia").html(flag ? "停牌" : formatNumber(d.ZuiXinJia)).addClass(d.ZhangFu>0?"red":"green").end()
				.find(".ZhangDie").html(formatNumber(d.ZhangDie)).addClass(d.ZhangFu>0?"red":"green").end()
				.find(".ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end()
				.find(".ZuoShou").html(formatNumber(d.ZuoShou)).end().find(".KaiPanJia").html(formatNumber(d.KaiPanJia)).end()
				.find(".ZuiGaoJia").html(formatNumber(d.ZuiGaoJia)).end().find(".ZuiDiJia").html(formatNumber(d.ZuiDiJia)).end()
				.find(".ChengJiaoLiang").html(formatNumber(d.ChengJiaoLiang,0)).end().find(".HuanShou").html(formatNumber(d.HuanShou)).end()
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
                        <!-- 我的自选股 -->
                        <div class=" clearfix">
                            <ul class=" tab-style-c">
                                <li class="active"><a href="javascript:void(0);">我的自选股</a></li>
                            </ul>
                            <div class="panel" style="display:block">
                                <table id="mystockTable"  class="display table-style-a table-sort">
                                    <col width="60"><col width="80"><col width=""><col width=""><col width="">
                                    <col width=""><col width=""><col width=""><col width=""><col width="">
                                    <col width=""><col width="40">
                                    <thead>
	                                    <tr>
	                                    	<th>代码</th>
	                                    	<th>名称</th>
	                                    	<th data-sort="float"><span class="sort_able">最新价</span></th>
	                                    	<th data-sort="float"><span class="sort_able">涨跌额</span></th>
	                                    	<th data-sort="string"><span class="sort_able">涨跌幅</span></th>
	                                    	<th>昨收</th>
	                                    	<th>今开</th>
	                                    	<th>最高</th>
	                                    	<th>最低</th>
	                                    	<th>成交量</th>
	                                    	<th>换手</th>
	                                    	<th class="no-pd"></th>
	                                    </tr>
                                    </thead>
                                    <tbody id="mystockBody"></tbody>
                                </table>
                                <div class="pagination"></div>
                            </div>
                        </div>
                        <!-- 我的自选股 -->
                    </div>
                    <!-- left-column -->
                    
                    <!-- right-column -->
                    <div class="right-column">
                        <div class="right-ad">
                            <a href="#"><img src="temp/ads.jpg"></a>
                        </div>
                    </div>
                    <!-- right-column -->
                    
                </div>
            </div>
        </div>
    </div>
</body>
</html>