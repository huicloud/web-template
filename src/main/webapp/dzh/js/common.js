/* ----- addHome --------------------------------------- */
function addHome(){var vDomainName='http://'+document.domain+'/';if(window.sidebar){try{netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");}catch(e){alert("此操作被浏览器拒绝！\n请在浏览器地址栏输入'about:config'并回车\n然后将[signed.applets.codebase_principal_support]设置为true");}var prefs=Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);prefs.setCharPref("browser.startup.homepage",vDomainName);}else if(document.all){document.body.style.behavior="url(#default#homepage)";document.body.setHomePage(vDomainName);}else{;}}
/* ----- addFavorite ----------------------------------- */
function addFavorite(){var sURL='',sTitle='';sURL=window.location;sTitle=document.title;try{window.external.addFavorite(sURL, sTitle);}catch(e){try{window.sidebar.addPanel(sTitle,sURL,"");}catch(e){alert("加入收藏失败，请使用Ctrl+D进行添加");}}}
/* ----- length2: chinese string's length -------------- */
String.prototype.length2 = function(){var cArr=this.match(/[^\x00-\xff]/ig);return this.length+(cArr==null?0:cArr.length);}

/* ----- jQuery common functions ----------------------- */
$(document).ready(function(){
	//tabs
	(function($){
		$('ul.tabs').each(function(){
			var parent=$(this),contents=$(this).nextAll('.panel'),tabs=$(this).find('li');
			if(tabs.length>0){
				tabs.each(function(index){
					var currentObj=$(this);currentObj.bind('click',function(){if(!currentObj.hasClass('active')){tabs.removeClass("active").eq(index).addClass("active");contents.hide().eq(index).show();}return false;});
					if(parent.attr('action') && parent.attr('action')=='hover'){currentObj.mouseover(function(){currentObj.trigger('click')});}
				});
			}
		});
	})(jQuery);
	
	
	//scroll news
	$(function(){
		var _interval=5000,_moving,_play=false,
		_animate=function(){
			_moving=setInterval(function(){
				var _field=_wrap.find('li:first');//此变量不可放置于函数起始处,li:first取值是变化的
				var _h=_field.height();//取得每次滚动高度
				_field.animate({marginTop:-_h+'px'},600,function(){//通过取负margin值,隐藏第一行
					_field.css('marginTop',0).appendTo(_wrap);//隐藏后,将该行的margin值置零,并插入到最后,实现无缝滚动
				})
			},_interval)//滚动间隔时间取决于_interval
		};
		var _wrap=$('#rollnews_box ul');//定义滚动区域
		if(_wrap.length>0){
			_wrap.hover(function(){
				clearInterval(_moving);_play=false;
			},function(){
				_play=true;_animate();
			}).trigger('mouseleave');//函数载入时,模拟执行mouseleave,即自动滚动
			_wrap.siblings('a').eq(0).click(function(){
				if(_play){$(this).attr('class','control_play').attr('title','播放');_wrap.trigger('mouseover');}
				else{$(this).attr('class','control_pause').attr('title','暂停');_wrap.trigger('mouseleave');}
				return false;
			});
		}
	});
	
	//table hover
	(function($){
		$('.tablehover').each(function(){$(this).find('tr:not(.nohover)').hover(function(){$(this).addClass("hover");},function(){$(this).removeClass("hover");})});
	})(jQuery);
	
	
	//fixed right-column
	(function($){
	    if($('.right-column').length>0){
	        var fixedElement = $('.right-column'),
                rtop = $('.site-header').children().outerHeight(true),
                offset = fixedElement.offset();
	        $(window).scroll(function(){
                if($(window).scrollTop() > (offset.top-rtop)){
                    fixedElement.css({'left':offset.left,'top':rtop}).addClass('fixed');
                } else {
                    fixedElement.css({'left':0,'top':0}).removeClass('fixed');
                }    
            });
	    }
    })(jQuery);
    
    //fixed nav
    (function($){
        if($('.site-header').length>0){
            var fixedElement = $('.site-header'),
                offset = fixedElement.offset();
            fixedElement.css('height',fixedElement.children().outerHeight(true));
            $(window).scroll(function(){
                if($(window).scrollTop() > offset.top){
                    fixedElement.addClass('fixed');
                } else {
                    fixedElement.removeClass('fixed');
                }    
            });
		}
    })(jQuery);
    
});

Date.prototype.format = function(format) {
	var d, k, o;
	o = {
		"M+": this.getMonth() + 1,
		"d+": this.getDate(),
		"h+": this.getHours(),
		"m+": this.getMinutes(),
		"s+": this.getSeconds(),
		"q+": Math.floor((this.getMonth() + 3) / 3),
		"S": this.getMilliseconds()
	};
	if (/(y+)/.test(format)) {
		format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
	}
	for (k in o) {
		d = o[k];
		if (new RegExp("(" + k + ")").test(format)) {
			format = format.replace(RegExp.$1, RegExp.$1.length === 1 ? d : ("00" + d).substr(("" + d).length));
		}
	}
	return format;
};

//格式化 新闻 时间
function formatNewsTime(d, t) {
	var s = "";
	switch(t){
		case 1: s = d.substring(4,6) + "-" + d.substring(6,8) + " " + d.substring(8,10) + ":" + d.substring(10,12); break;
		case 2: s = d.substring(8,10) + ":" + d.substring(10,12); break;
	}
	return s;
}

//格式化 公告 时间
function formatGgTime(d, t) {
	var s = "";
	switch(t){
		case 1: s = d.substring(0,4) + "-" + d.substring(4,6) + "-" + d.substring(6,8); break;
		case 2: s = d.substring(4,6) + "-" + d.substring(6,8); break;
	}
	return s;
}

//新闻、公告 tilte截断处理
function formatTitle(t, l) {
	t = t.trim();
	return t.length>l ? t.substring(0,l)+"..." : t;
}

//投资评级 字符串转化为 int
function getPinJiNum(str) {
	var p = 0;
	if (str=="卖出") {
		p = 1;
	} else if (str == "减持") {
		p = 2;
	} else if (str == "中性") {
		p = 3;
	} else if (str == "增持") {
		p = 4;
	} else if (str == "买入") {
		p = 5;
	}
	return p; 
}

//停牌判断 ZuiXinJia无效, 并且WeiTuoMaiRuJia1,WeiTuoMaiChuJia1都无效才视为停牌
function isTingPai(ZuiXinJia, WeiTuoMaiRuJia1, WeiTuoMaiChuJia1) {
	var b = false;
	if (!ZuiXinJia && !WeiTuoMaiRuJia1 && !WeiTuoMaiChuJia1) b = true;
	return b;
}

/**
   * 格式化文本，将输入的数字参数格式化为指定精度的字符串
   * @param {!number|string|null} data      需要格式化的数字，可以是数字，字符串或者null对象
   * @param {?number} precision             保留小数精度，null则默认取2位小数
   * @param {?''|'K'|'M'|'W'|'Y'|'K/M'|'%'} unit    单位，按自定的单位格式化数据，null则为''为不加单位
   * @param suffix 后缀，自定义后缀
   * @returns {string}
   */
var formatNumber = function(data, precision, unit, suffix) {
    if (data == null) {
        data = 0;
    }

    var n = Number(data);
    if ((n == 0 || isNaN(n))) {
        return "-";
    }

    unit = unit || '';
    precision = precision != null ? precision : 2;
    suffix = suffix || '';

    switch(unit) {
        case '%': n = n * 100; break;
        case 'K': n = n / 1000; break;
        case 'M': n = n / (1000 * 1000); break;
        case 'W': n = n / 10000; break;
        case 'Y': n = n / (10000 * 10000); break;
        case 100: n = n / 100; break;
    }
    return n.toFixed(precision) + suffix;
};

//键盘宝
function kbspirit(inputDomain, bindSelect) {
	inputDomain.focusin(function(){
		$(this).val("");
	});
	
	var kbspiritDataStore = new DataStore({
        serviceUrl: "/kbspirit",
        otherParams: {type: 0}
    });
			
	inputDomain.autocomplete({
		autoFocus: true,
		source : function(request,response){
			kbspiritDataStore.query({
				input: request.term
			}).then(function(data){
				var result = data[0] && data[0].JieGuo;
				result.forEach(function (eachData) {
					var shuJu = eachData.ShuJu;
					var keyData = [];
					$.each(shuJu, function(i,item){
						keyData.push({
							value: item.DaiMa,
							label: item.MingCheng,
							desc: item.MingCheng
						});
					});
					response(keyData);
				});
			})
		},
		focus: function(event, ui) {
	        //inputDomain.val( ui.item.label );
	    	return false;
	    },
		select : function(event, ui) {
			bindSelect(ui.item.value);
			return false;
		}
	}).autocomplete( "instance" )._renderItem = function( ul, item ) {
      return $("<li>").append("<a>" + item.value + " " + item.desc + "</a>" ).appendTo(ul);
    };
}