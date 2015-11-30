<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">

$(function(){
	
	var bkDataStore = new DataStore({ //板块排行
		serviceUrl: "/sort/range",
		fields: "ZhangFu",
		otherParams: { start: 0, count: 4 }
	});
	var dynaDataStore = new DataStore({ //动态行情数据源
        serviceUrl: "/stkdata"
    });
	
	valBk();
	
	function valBk() {
		var df1 = new $.Deferred();
		var df2 = new $.Deferred();
		
		bkDataStore.cancel();
		var resp1 = bkDataStore.query({ //涨幅排行
			desc: true,
			market: "B$"
		});
		var resp2 = bkDataStore.query({ //跌幅排行
			desc: false,
			market: "B$"
		});
		
		resp1.then(function(data){
			valUl($("#lingzhangul"), data);
			df1.resolve(data);
			
		});
		resp2.then(function(data){
			valUl($("#lingdieul"), data);
			df2.resolve(data);
		});
		
		function valUl(ul, data) {
			var temp = [];
			ul.empty();
			$.each(data,function(i, item){
				temp.push("<li class='bk_" + item.Obj.substr(2) + "'>");
				temp.push("<div class='plate-category micro ZhongWenJianCheng'></div>");
				temp.push("<div class='plate-percent micro ZhangFu'></div>");
//				temp.push("<div class='plate-top lingzhanggegu'></div>");
//				temp.push("<div class='plate-top-detail red'><span>5.45</span><span>10.10%</span></div>");
				temp.push("</li>");
			});
			ul.html(temp.join(""));
		}
		
		$.when(df1, df2).then(function(d1, d2){
			var stkCode = [];
			$.each(d1,function(i, item){ stkCode.push(item.Obj); });
			$.each(d2,function(i, item){ stkCode.push(item.Obj); });
			
			dynaDataStore.cancel();
			dynaDataStoreSubscribe(dynaDataStore, stkCode);
		});
	}
	
	function dynaDataStoreSubscribe(dynaDataStore, stkCode) {
		dynaDataStore.subscribe({
			obj: stkCode,
			field: "ZhongWenJianCheng,ZuiXinJia,ZhangFu"
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
			var li = $("li.bk_"+d.Obj.substr(2));	
			li.find("div.ZhongWenJianCheng").html(d.ZhongWenJianCheng).end()
			.find("div.ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end()
			;
		}
	}
	
});
</script>

<div class="plate-data content-box clearfix">
    <ul class="tabs tab-style-c">
        <li class="active"><a href="javascript:void(0);">板块概念</a></li>
    </ul>
    <div style="display: block;" class="panel">
        <h3 class="h3-title"><span>领涨行业</span></h3>
        <ul class="plate-list" id="lingzhangul"></ul>
        <h3 class="h3-title"><span>领跌行业</span></h3>
        <ul class="plate-list" id="lingdieul"></ul>
    </div>
</div>