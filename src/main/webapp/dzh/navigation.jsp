<%@ page language="java" pageEncoding="UTF-8"%>

<script type="text/javascript">

$(function(){
	//个股行情
	var navigationDiv = $("#navigationDiv");
	var gghqNav = $("#navigationDiv ul.nav li.gp");
	var gghqSubNav = $("div.subnav");
	var path = "<%=request.getServletPath()%>";

	if (path) {
		var currpath = path.substr(path.lastIndexOf("/")+1);
		if (currpath.indexOf("gghq")>-1) {
			gghqSubNav.show();
			navigationDiv.addClass("hasChild");
			gghqNav.addClass("selected");
			gghqSubNav.find("a."+currpath.substring(0,currpath.length-4)).addClass("selected");
		} else {
			$("#navigationDiv ul.nav li."+currpath.substring(0,currpath.length-4)).addClass("selected");
		}
	}
	
	gghqNav.mouseenter(function(){
		gghqSubNav.show();
		navigationDiv.addClass("hasChild");
	}).siblings().mouseenter(function(){
		gghqSubNav.hide();
		gghqNav.removeClass("selected");
		navigationDiv.removeClass("hasChild");
	});
	
	//键盘宝
    (function($){
    	kbspirit($("#searchtext"), function(stockCode) {
    		window.location.href = rootPath+"/dzh/gghq_ggsy.jsp?stockCode=" + stockCode;
    	});
    })(jQuery);
	
});

</script>

<!-- 导航栏  -->
<div id="navigationDiv" class="header-nav">
    <div class="container">
        <div class="nav-search">
        	<input type="text" accesskey="s" id="searchtext" class="searchtext" name="keywords" autocomplete="off" value="代码/名称/拼音" />
        </div>

        <!-- nav -->
        <ul class="nav">
            <li class="hqsy"><a href="hqsy.jsp"><span>行情首页</span></a></li><li class="line"></li>
            <li class="gp"><a href="javascript:void(0);"><span>股票</span></a></li><li class="line"></li>
            <li class="zdph"><a href="zdph.jsp"><span>涨跌排行</span></a></li><li class="line"></li>
            <li class="bkgn"><a href="bkgn.jsp"><span>板块概念</span></a></li><li class="line"></li>
            <li class="xwzx"><a href="xwzx.jsp"><span>新闻中心</span></a></li><li class="line"></li>
            <li class="ggzx"><a href="ggzx.jsp"><span>公告中心</span></a></li><li class="line"></li>
            <li class="mystocks"><a href="mystocks.jsp"><span>我的自选股</span></a></li>
        </ul>
        <!-- nav -->
        
        <div class="subnav clearfix" style="display: none;" >
            <a class="gghq_ggsy" href="gghq_ggsy.jsp">个股首页</a>
            <a class="gghq_gsxw" href="gghq_gsxw.jsp">公司新闻</a>
            <a class="gghq_gsgg" href="gghq_gsgg.jsp">公司公告</a>
            <a class="gghq_ylyq" href="gghq_ylyq.jsp">盈利预期</a>
            <a class="gghq_gsjs" href="gghq_gsjs.jsp">公司介绍</a>
            <a class="gghq_zjlx" href="gghq_zjlx.jsp">资金流向</a>
            <a class="gghq_gbgd" href="gghq_gbgd.jsp">股本股东</a>
            <a class="gghq_cwfx" href="gghq_cwfx.jsp">财务分析</a>
            <a class="gghq_gbfh" href="gghq_gbfh.jsp">股本分红</a>
        </div>

    </div>
</div>
<!-- 导航栏  -->