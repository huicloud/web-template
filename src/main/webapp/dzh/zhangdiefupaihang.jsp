<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">
$(function(){
	
	//填充前五名涨跌幅榜的body
	(function($){
		valBody($("#zfBody"));
		valBody($("#5zfBody"));
		valBody($("#dfBody"));
		valBody($("#5dfBody"));
		
		function valBody(tbody) {
			var temp = [];
			tbody.empty();
			for(var i=0; i<5; i++) {
				temp.push("<tr><td class='count'>"+(i+1)+"</td>");
				temp.push("<td class='ZhongWenJianCheng'></td><td class='ZuiXinJia'></td>");
				temp.push("<td class='ZhangFu'></td><td class='ZhenFu'></td></tr>");
			}
			tbody.html(temp.join(""));
		}
	})(jQuery);
	
	var sortDataStore = new DataStore({ //涨跌幅排行数据源
		serviceUrl: "/sort/range",
		otherParams: { start: 0, count: 5 }
	});
	var dynaDataStore = new DataStore({ //动态行情数据源
        serviceUrl: "/stkdata"
    });
	
	var intervalID;
	$("#shichangul li").click(function(){
		$(this).addClass("active").siblings().removeClass("active");
		var sc = $(this).attr("sc");
		valZhangDieFu(sc);
//		if(intervalID) clearInterval(intervalID);
//		intervalID = setInterval(function(){valZhangDieFu(sc);}, 10000);
	});
	
	$("#shichangul li:eq(0)").trigger("click");
	
	function valZhangDieFu(sc) {
		var df1 = new $.Deferred();
		var df2 = new $.Deferred();
		var df3 = new $.Deferred();
		var df4 = new $.Deferred();

		sortDataStore.cancel();
		var resp1 = sortDataStore.subscribe({ //涨幅排行
			desc: true,
			field: "ZhangFu",
			gql: getZdfGql(sc)
		});
		var resp2 = sortDataStore.subscribe({ //跌幅排行
			desc: false,
			field: "ZhangFu",
			gql: getZdfGql(sc)
		});
		
		var resp3 = sortDataStore.subscribe({ //5分钟涨幅排行
			desc: true,
			field: "FenZhongZhangFu5",
			gql: getZdfGql(sc)
		});
		var resp4 = sortDataStore.subscribe({ //5分钟跌幅排行
			desc: false,
			field: "FenZhongZhangFu5",
			gql: getZdfGql(sc)
		});
		
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
		
		resp1.then(function(data){
			valStocks($("#zfBody"), data);
			df1.resolve(data);
			
		});
		resp2.then(function(data){
			valStocks($("#dfBody"), data);
			df2.resolve(data);
		});
		resp3.then(function(data){
			valStocks($("#5zfBody"), data);
			df3.resolve(data);
			
		});
		resp4.then(function(data){
			valStocks($("#5dfBody"), data);
			df4.resolve(data);
		});
		function valStocks(tbody, data) {	
			var tr,count = 0;
			$.each(data,function(i, item){
				tr = tbody.find("tr:eq("+(count++)+")");
				tr.attr("class", "zdf_"+item.Obj);
				tr.find(".ZhongWenJianCheng").css("cursor","pointer")
				.bind("mouseenter",function(){
					$(this).addClass("blue");
				}).bind("mouseleave",function(){
					$(this).removeClass("blue");
				}).end()
				.find(".ZuiXinJia").removeClass("red green").end()
    			.find(".ZhangFu").removeClass("red green").end()
    			.find(".ZhenFu").removeClass("red green").end();
			});
		}

		$.when(df1, df2, df3, df4).then(function(d1, d2, d3, d4){
			var stkCode = [];
			
			$.each(d1,function(i, item){ stkCode.push(item.Obj); });
			$.each(d2,function(i, item){ stkCode.push(item.Obj); });
			$.each(d3,function(i, item){ stkCode.push(item.Obj); });
			$.each(d4,function(i, item){ stkCode.push(item.Obj); });
			
			dynaDataStore.cancel();
			dynaDataStoreSubscribe(dynaDataStore, stkCode);
		});
	}
	
	function dynaDataStoreSubscribe(dynaDataStore, stkCode) {
		dynaDataStore.subscribe({
			obj: stkCode,
			field: "ZhongWenJianCheng,ZuiXinJia,ZhangFu,ZhenFu"
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
			tr.find(".ZhongWenJianCheng").html(d.ZhongWenJianCheng).bind("click",function(){
				window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + d.Obj;
			}).end()
			.find(".ZuiXinJia").html(formatNumber(d.ZuiXinJia)).addClass(d.ZhangFu>0?"red":"green").end()
			.find(".ZhangFu").html(formatNumber(d.ZhangFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end()
			.find(".ZhenFu").html(formatNumber(d.ZhenFu,null,null,"%")).addClass(d.ZhangFu>0?"red":"green").end();
		}
	}

});

</script>

<div class="plate-data content-box clearfix">
    <ul id="shichangul" class="tab-style-c">
        <li sc="hushenagu" class="active"><a href="javascript:void(0);">沪深A股</a></li>
        <li sc="zhongxiaoban"><a href="javascript:void(0);">中小板</a></li>
        <li sc="chuangyeban"><a href="javascript:void(0);">创业板</a></li>
    </ul>
    <div style="display: block;" class="panel plate-tb-list">
    	<div class="plate-data-tb">
            <h3 class="h3-title"><span>涨幅排行</span></h3>
            <table width="100%" class="table-style-f">
                <colgroup><col width=""><col width=""><col width=""><col width=""><col width=""></colgroup>
                <thead><tr><td>排名</td><td>名称</td><td>最新价</td><td>涨跌幅</td><td>振幅</td></tr></thead>
                <tbody id="zfBody"></tbody>
            </table>
        </div>
        <div class="plate-data-tb">
            <h3 class="h3-title"><span>5分钟涨幅排行</span></h3>
            <table width="100%" class="table-style-f">
                <colgroup><col width=""><col width=""><col width=""><col width=""><col width=""></colgroup>
                <thead><tr><td>排名</td><td>名称</td><td>最新价</td><td>涨跌幅</td><td>振幅</td></tr></thead>
                <tbody id="5zfBody"></tbody>
            </table>
        </div>
        <div class="plate-data-tb">
            <h3 class="h3-title"><span>跌幅排行</span></h3>
            <table width="100%" class="table-style-f">
                <colgroup><col width=""><col width=""><col width=""><col width=""><col width=""></colgroup>
                <thead><tr><td>排名</td><td>名称</td><td>最新价</td><td>涨跌幅</td><td>振幅</td></tr></thead>
                <tbody id="dfBody"></tbody>
            </table>
        </div>
        <div class="plate-data-tb">
            <h3 class="h3-title"><span>5分钟跌幅排行</span></h3>
            <table width="100%" class="table-style-f">
                <colgroup><col width=""><col width=""><col width=""><col width=""><col width=""></colgroup>
                <thead><tr><td>排名</td><td>名称</td><td>最新价</td><td>涨跌幅</td><td>振幅</td></tr></thead>
                <tbody id="5dfBody"></tbody>
            </table>
        </div>
    </div>
</div>
