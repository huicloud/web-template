<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">

var myCode = [], pageCodes = [], resultCode = 1;
//动态行情数据源 专门处理 自选股
var mystockDynaDataStore = new DataStore({
    serviceUrl: "/stkdata"
});

$(function(){
	
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
				
				//如果当前股票在自选股中，则去除增加自选股的按钮
				if($.inArray(currCode, myCode) > -1) {
					$("#addstock").hide();
				}
			}
		},
		complete: function() {
			if (resultCode == 0 && myCode.length>0) {
				var arr = [];
				$.each(myCode,function(i, item){
					arr.push("<tr id='mystock_"+item+"' code='"+item+"'>");
					arr.push("<td class='obj'>"+item+"</td><td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td><td class='ZhangFu'></td>");
					arr.push("<td class='ZhenFu'></td><td class='no-pd'><a href='javascript:void(0)' class='del-stock-btn hide'></a></td></tr>");
    			});
				$("#mystockBody").html(arr.join(""));
				
				editStock();
				
				pageMystock();
			}
		}
	});
});

function pageMystock() {
	$("#mystockTable").stupidtable();
	$("#mystockPagination").jPages({
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
			pageCodes.length = 0;
			$.each(s, function(i,item){
				pageCodes.push(item.getAttribute("code"));
			});
			
			mystockDynaDataStore.cancel();
			mystockDynaDataStoreSubscribe(mystockDynaDataStore, pageCodes);
		}
	});
}

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
					//从pageCodes中删除
					var index = $.inArray(tr.find(".obj").html(), pageCodes);
					pageCodes.splice(index, 1);
					
					mystockDynaDataStore.cancel();
					mystockDynaDataStoreSubscribe(mystockDynaDataStore, pageCodes);
				}
			}
		});
	});
}

function mystockDynaDataStoreSubscribe(dynaDataStore, stkCode) {
	dynaDataStore.subscribe({
		obj: stkCode,
		field: "ZhongWenJianCheng,ZuiXinJia,ZhangFu,ZhenFu,WeiTuoMaiRuJia1,WeiTuoMaiChuJia1"
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
		.find(".ZhongWenJianCheng").html(d.ZhongWenJianCheng).css("cursor","pointer").bind("click",function(){
			window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + d.Obj;
		});
		
		// 如果最新价是NaN，做停牌处理
		var flag = isTingPai(d.ZuiXinJia, d.WeiTuoMaiRuJia1, d.WeiTuoMaiChuJia1);
		mystock_stk.find(".ZuiXinJia").html(flag ? "停牌" : formatNumber(d.ZuiXinJia)).addClass(d.ZhangFu>0?"red":"green").end()
		.find(".ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end()
		.find(".ZhenFu").html(formatNumber(d.ZhenFu,null,null,"%")).end()
		;
	}
}
</script>

<div class="sim-box mystock-right">
    <h3>我的自选股</h3>
    <div class="sim-box-content">
        <table width="100%" class="table-style-f">
            <col width=""><col width=""><col width=""><col width=""><col width=""><col width="40">
            <tr><th>代码</th><th>名称</th><th>最新价</th><th>涨跌幅</th><th>振幅</th><th></th></tr>
            <tbody id="mystockBody"></tbody>
        </table>
        <div id="mystockPagination" class="pagination"></div>
    </div>
</div>