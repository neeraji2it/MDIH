// page init
jQuery(function(){
    jcf.customForms.replaceAll();
    initCarousel();
    //initLightbox();
    initSlideShow();
    initTabs();
    initInputs();
    initOpenClose();
    initSlider();
    initPopupBlock();
});

jQuery(window).load(function(){
    initGallerySlider();
});



//init popups controll
function initPopupBlock() {
	var activeClass = 'active';
	var colapseClass = 'collapseblock';
	var colVideoClass = 'video-open';
	var animeSpeed = 400;
	var openMass = [];
	jQuery('.message-nav').each(function() {
		var holderList = jQuery(this);
		var openPopup = holderList.find('.open-persone-popup');
		var popup = jQuery(openPopup.attr('href'));
		var closeBtn = popup.find('.close');
		var btnCollapse = popup.find('.window-nav .item-1');
		var popupContent = popup.find('.popup-content-area');
		var openIn = popup.find('.chat-nav .item-3');
		var btnVideo = popup.find('.chat-nav .item-2');
		var videoBox = popup.find('.camera-holder');

		//position
		function iniPosition() {
			var masLength = openMass.length;
			var offset = 0;
			if(masLength){
				for(var i = 0; i < masLength; i++){
					offset += openMass[i].outerWidth();
				}
			}
			popup.css({
				left:jQuery(window).width() - offset,
				top:jQuery(window).height() - popup.outerHeight() - parseInt(popup.css('margin-top')) + jQuery(window).scrollTop()
			});
		}

		//reposition
		function reposition(){
			var masLength = openMass.length;
			var offset = 0;
			if(masLength){
				for(var i = 0; i < masLength; i++){
					offset += openMass[i].outerWidth();
					openMass[i].css({
						left:jQuery(window).width() - offset,
						top:jQuery(window).height() - popup.outerHeight() - parseInt(popup.css('margin-top')) + jQuery(window).scrollTop()
					});
				}
			}
		}

		//open popup init
		openPopup.click(function(){
			if(openPopup.hasClass(activeClass)){
				popup.hide();
				openMass = $(openMass).filter(function(a,b){
					if(b === popup){
						return false;
					}else{
						return true;
					}
				});
				openPopup.removeClass(activeClass);
			}
			else{
				openMass.push(popup);
				iniPosition();
				popup.show();
				openPopup.addClass(activeClass);
			}
			return false;
		});

		//close popup init function
		closeBtn.click(function(){
			if(openPopup.hasClass(activeClass)){
				popup.hide();
				openMass = $(openMass).filter(function(a,b){
					if(b === popup){
						return false;
					}else{
						return true;
					}
				});
				openPopup.removeClass(activeClass);
			}
			else{
				openMass.push(popup);
				iniPosition();
				popup.show();
				openPopup.addClass(activeClass);
			}
			return false;
		});

		//init draggable
		popup.draggable({
			start: function(event, ui) {
				//openMass.pop();
				openMass = $(openMass).filter(function(a,b){
					if(b === popup){
						return false;
					}else{
						return true;
					}
				});
				reposition();
			},
			zIndex: 2700
		});

		//collapse main content popup
		btnCollapse.click(function(){
			if(popup.hasClass(colapseClass)){
				popupContent.slideUp(animeSpeed);
				popup.removeClass(colapseClass);
			}
			else{
				popupContent.slideDown(animeSpeed);
				popup.addClass(colapseClass);
			}
			return false;
		});

		//open new window
		openIn.click(function(){
			var openInCur = openIn.attr('href');
			window.open(openInCur, "JSSite" , "width=352,height=631");
			return false;
		});

		//open video box
		btnVideo.click(function(){
			if(popup.hasClass(colVideoClass)){
				videoBox.slideUp(animeSpeed);
				popup.removeClass(colVideoClass);
			}
			else{
				videoBox.slideDown(animeSpeed);
				popup.addClass(colVideoClass);
			}
			return false;
		});

		iniPosition();
		jQuery(window).bind('resize scroll', function(){
			iniPosition();
			reposition();
		});
	});
}


//slider init
function initSlider() {
    jQuery('.slide-price').each(function(){
        var holder = $(this);
        var progressBar = holder.find('.progress-bar');
        var rangeMin = holder.find('.range');
        var rangeMax = holder.find('.range-max');
		
        var minVal = parseFloat(holder.find('.min-val').val());
        var maxVal = parseFloat(holder.find('.max-val').val());
        var minCurVal = parseFloat(holder.find('.cur-val-min').val());
        var maxCurVal = parseFloat(holder.find('.cur-val-max').val());
		
		
        // slider
        progressBar.slider({
            range: true,
            min: minVal,
            max: maxVal,
            values: [ minCurVal, maxCurVal ],
            slide: function( event, ui){
                rangeMin.val(ui.values[0]);
                rangeMax.val(ui.values[1]);
            }
        });
        rangeMin.val(progressBar.slider('values', 0));
        rangeMax.val(progressBar.slider('values', 1));
    });
}

function initGallerySlider(){
    var demo = {
        yScroll: function(wrapper, scrollable) {
            var wrapper = $(wrapper), scrollable = $(scrollable),
            loading = $('<div class="loading">Loading...</div>').appendTo(wrapper),
            internal = null,
            images	= null;
            scrollable.hide();
            images = scrollable.find('img');
            completed = 0;
				
            images.each(function(){
                if (this.complete) completed++;
            });
				
            if (completed == images.length){
                setTimeout(function(){
                    loading.hide();
                    wrapper.css({
                        overflow: 'hidden'
                    });
                    scrollable.slideDown('slow', function(){
                        enable();
                    });
                }, 0);
            }
		
			
            function enable(){
                var inactiveMargin = 99,
                wrapperWidth = wrapper.width(),
                wrapperHeight = wrapper.height(),
                scrollableHeight = scrollable.outerHeight() + 2*inactiveMargin,
                wrapperOffset = 0,
                top = 0,
                lastTarget = null;

				
                wrapper.mousemove(function(e){
                    lastTarget = e.target;
                    wrapperOffset = wrapper.offset();
                    top = (e.pageY -  wrapperOffset.top) * (scrollableHeight - wrapperHeight) / wrapperHeight - inactiveMargin;
                    if (top < 0){
                        top = 0;
                    }
                    wrapper.scrollTop(top);
                });
            }
        }
    }
    demo.yScroll('#scroll-pane', 'ul#sortable');
}

// scroll gallery init
function initCarousel() {
    jQuery('div.person-slider').scrollGallery({
        animSpeed: 300,
        step: 1
    });
    jQuery('div.profile-slider').scrollGallery({
        animSpeed: 300,
        step: 1
    });
}

// slideshow init
function initSlideShow() {
    jQuery('div.photo-slider').fadeGallery({
        slides: '.slide'
    });
}

// tabs init
function initTabs() {
    jQuery('ul.box-tabs').contentTabs({
        effect:'none'
    });
}

// open-close init
function initOpenClose() {
    jQuery('div.bar').openClose({
        addClassBeforeAnimation: false,
        activeClass:'expanded',
        opener:'a.user-link',
        slider:'div.user-drop',
        effect:'slide',
        easing:'easeOutBounce',
        animSpeed:800
    });
    jQuery('div.content-box').openClose({
        addClassBeforeAnimation: false,
        activeClass:'active',
        opener:'a.opener',
        slider:'div.slide',
        effect:'slide',
        easing:'easeOutBounce',
        animSpeed:800
    });
	
    jQuery('div.block').openClose({
        addClassBeforeAnimation: false,
        activeClass:'active',
        opener:'a.opener',
        slider:'div.slide',
        effect:'slide',
        easing:'easeOutBounce',
        animSpeed:800
    });
}

/*
 * jQuery Open/Close plugin
 */
;
(function($){
    $.fn.openClose = function(o){
        // default options
        var options = $.extend({
            addClassBeforeAnimation: true,
            activeClass:'active',
            opener:'.opener',
            slider:'.slide',
            easing:'easeInElastic',
            animSpeed: 400,
            animStart:false,
            animEnd:false,
            effect:'fade',
            event:'click'
        },o);

        return this.each(function(){
            // options
            var holder = $(this), animating;
            var opener = $(options.opener, holder);
            var slider = $(options.slider, holder);
            if(slider.length) {
                opener.bind(options.event,function(){
                    if(!animating) {
                        animating = true;
                        if(typeof options.animStart === 'function') options.animStart();
                        if(holder.hasClass(options.activeClass)) {
                            toggleEffects[options.effect].hide({
                                speed: options.animSpeed,
                                easing: options.easing,
                                box: slider,
                                complete: function() {
                                    animating = false;
                                    if(!options.addClassBeforeAnimation) {
                                        holder.removeClass(options.activeClass);
                                    }
                                    if(typeof options.animEnd === 'function') options.animEnd();
                                }
                            });
                            if(options.addClassBeforeAnimation) {
                                holder.removeClass(options.activeClass);
                            }
                        } else {
                            if(options.addClassBeforeAnimation) {
                                holder.addClass(options.activeClass);
                            }
                            toggleEffects[options.effect].show({
                                speed: options.animSpeed,
                                box: slider,
                                complete: function() {
                                    animating = false;
                                    if(!options.addClassBeforeAnimation) {
                                        holder.addClass(options.activeClass);
                                    }
                                    if(typeof options.animEnd === 'function') options.animEnd();
                                }
                            })
                        }
                    }
                    return false;
                });
                if(holder.hasClass(options.activeClass)) {
                    slider.show();
                }
                else {
                    slider.hide();
                }
            }
        });
    }
	
    // animation effects
    var toggleEffects = {
        slide: {
            show: function(o) {
                o.box.slideDown(o.speed, o.complete);
            },
            hide: function(o) {
                o.box.slideUp(o.speed, o.easing, o.complete);
            }
        },
        fade: {
            show: function(o) {
                o.box.fadeIn(o.speed, o.complete);
            },
            hide: function(o) {
                o.box.fadeOut(o.speed, o.complete);
            }
        },
        none: {
            show: function(o) {
                o.box.show(0, o.complete);
            },
            hide: function(o) {
                o.box.hide(0, o.complete);
            }
        }
    }
}(jQuery));

/*
 * jQuery Tabs plugin
 */
;
(function($){
    $.fn.contentTabs = function(o){
        // default options
        var options = $.extend({
            activeClass:'active',
            addToParent:false,
            autoHeight:false,
            autoRotate:false,
            animSpeed:400,
            switchTime:3000,
            effect: 'none', // "fade", "slide"
            tabLinks:'a',
            event:'click'
        },o);

        return this.each(function(){
            var tabset = $(this);
            var tabLinks = tabset.find(options.tabLinks);
            var tabLinksParents = tabLinks.parent();
            var prevActiveLink = tabLinks.eq(0), currentTab, animating;
            var tabHolder;
			
            // init tabLinks
            tabLinks.each(function(){
                var link = $(this);
                var href = link.attr('href');
                var parent = link.parent();
                href = href.substr(href.lastIndexOf('#'));
				
                // get elements
                var tab = $(href);
                link.data('cparent', parent);
                link.data('ctab', tab);
				
                // find tab holder
                if(!tabHolder && tab.length) {
                    tabHolder = tab.parent();
                }
				
                // show only active tab
                if((options.addToParent ? parent : link).hasClass(options.activeClass)) {
                    prevActiveLink = link;
                    currentTab = tab;
                    tab.removeClass(tabHiddenClass).width('');
                    contentTabsEffect[options.effect].show({
                        tab:tab,
                        fast:true
                    });
                } else {
                    contentTabsEffect[options.effect].hide({
                        tab:tab,
                        fast:true
                    });
                    tab.width(tab.width()).addClass(tabHiddenClass);
                }
				
                // event handler
                link.bind(options.event, function(e){
                    if(link != prevActiveLink && !animating) {
                        switchTab(prevActiveLink, link);
                        prevActiveLink = link;
                    }
                    e.preventDefault();
                });
                if(options.event !== 'click') {
                    link.bind('click', function(e){
                        e.preventDefault();
                    });
                }
            });
			
            // tab switch function
            function switchTab(oldLink, newLink) {
                animating = true;
                var oldTab = oldLink.data('ctab');
                var newTab = newLink.data('ctab');
                currentTab = newTab;
				
                // refresh pagination links
                (options.addToParent ? tabLinksParents : tabLinks).removeClass(options.activeClass);
                (options.addToParent ? newLink.data('cparent') : newLink).addClass(options.activeClass);
				
                // hide old tab
                resizeHolder(oldTab, true);
                contentTabsEffect[options.effect].hide({
                    speed: options.animSpeed,
                    tab:oldTab,
                    complete: function() {
                        // show current tab
                        resizeHolder(newTab.removeClass(tabHiddenClass).width(''));
                        contentTabsEffect[options.effect].show({
                            speed: options.animSpeed,
                            tab:newTab,
                            complete: function() {
                                oldTab.width(oldTab.width()).addClass(tabHiddenClass);
                                animating = false;
                                resizeHolder(newTab, false);
                                autoRotate();
                            }
                        });
                    }
                });
            }
			
            // holder auto height
            function resizeHolder(block, state) {
                var curBlock = block && block.length ? block : currentTab;
                if(options.autoHeight && curBlock) {
                    tabHolder.stop();
                    if(state === false) {
                        tabHolder.css({
                            height:''
                        });
                    } else {
                        var origStyles = curBlock.attr('style');
                        curBlock.show().css({
                            width:curBlock.width()
                        });
                        var tabHeight = curBlock.outerHeight(true);
                        if(!origStyles) curBlock.removeAttr('style'); else curBlock.attr('style', origStyles);
                        if(state === true) {
                            tabHolder.css({
                                height: tabHeight
                            });
                        } else {
                            tabHolder.animate({
                                height: tabHeight
                            }, {
                                duration: options.animSpeed
                            });
                        }
                    }
                }
            }
            if(options.autoHeight) {
                $(window).bind('resize orientationchange', function(){
                    resizeHolder(currentTab, false);
                });
            }
			
            // autorotation handling
            var rotationTimer;
            function nextTab() {
                var activeItem = (options.addToParent ? tabLinksParents : tabLinks).filter('.' + options.activeClass);
                var activeIndex = (options.addToParent ? tabLinksParents : tabLinks).index(activeItem);
                var newLink = tabLinks.eq(activeIndex < tabLinks.length - 1 ? activeIndex + 1 : 0);
                prevActiveLink = tabLinks.eq(activeIndex);
                switchTab(prevActiveLink, newLink);
            }
            function autoRotate() {
                if(options.autoRotate && tabLinks.length > 1) {
                    clearTimeout(rotationTimer);
                    rotationTimer = setTimeout(nextTab, options.switchTime);
                }
            }
            autoRotate();
        });
    }
	
    // add stylesheet for tabs on DOMReady
    var tabHiddenClass = 'js-tab-hidden';
    $(function() {
        var tabStyleSheet = $('<style type="text/css">')[0];
        var tabStyleRule = '.'+tabHiddenClass;
        tabStyleRule += '{position:absolute !important;left:-9999px !important;top:-9999px !important;display:block !important}';
        if (tabStyleSheet.styleSheet) {
            tabStyleSheet.styleSheet.cssText = tabStyleRule;
        } else {
            tabStyleSheet.appendChild(document.createTextNode(tabStyleRule));
        }
        $('head').append(tabStyleSheet);
    });
	
    // tab switch effects
    var contentTabsEffect = {
        none: {
            show: function(o) {
                o.tab.css({
                    display:'block'
                });
                if(o.complete) o.complete();
            },
            hide: function(o) {
                o.tab.css({
                    display:'none'
                });
                if(o.complete) o.complete();
            }
        },
        fade: {
            show: function(o) {
                if(o.fast) o.speed = 1;
                o.tab.fadeIn(o.speed);
                if(o.complete) setTimeout(o.complete, o.speed);
            },
            hide: function(o) {
                if(o.fast) o.speed = 1;
                o.tab.fadeOut(o.speed);
                if(o.complete) setTimeout(o.complete, o.speed);
            }
        },
        slide: {
            show: function(o) {
                var tabHeight = o.tab.show().css({
                    width:o.tab.width()
                }).outerHeight(true);
                var tmpWrap = $('<div class="effect-div">').insertBefore(o.tab).append(o.tab);
                tmpWrap.css({
                    width:'100%',
                    overflow:'hidden',
                    position:'relative'
                });
                o.tab.css({
                    marginTop:-tabHeight,
                    display:'block'
                });
                if(o.fast) o.speed = 1;
                o.tab.animate({
                    marginTop: 0
                }, {
                    duration: o.speed,
                    complete: function(){
                        o.tab.css({
                            marginTop: '',
                            width: ''
                        }).insertBefore(tmpWrap);
                        tmpWrap.remove();
                        if(o.complete) o.complete();
                    }
                });
            },
            hide: function(o) {
                var tabHeight = o.tab.show().css({
                    width:o.tab.width()
                }).outerHeight(true);
                var tmpWrap = $('<div class="effect-div">').insertBefore(o.tab).append(o.tab);
                tmpWrap.css({
                    width:'100%',
                    overflow:'hidden',
                    position:'relative'
                });
				
                if(o.fast) o.speed = 1;
                o.tab.animate({
                    marginTop: -tabHeight
                }, {
                    duration: o.speed,
                    complete: function(){
                        o.tab.css({
                            display:'none',
                            marginTop:'',
                            width:''
                        }).insertBefore(tmpWrap);
                        tmpWrap.remove();
                        if(o.complete) o.complete();
                    }
                });
            }
        }
    }
}(jQuery));

/*
 * jQuery SlideShow plugin
 */
;
(function($){
    function FadeGallery(options) {
        this.options = $.extend({
            slides: 'ul.slideset > li',
            activeClass:'active',
            disabledClass:'disabled',
            btnPrev: 'a.btn-prev',
            btnNext: 'a.btn-next',
            generatePagination: false,
            pagerList: '<ul>',
            pagerListItem: '<li><a href="#"></a></li>',
            pagerListItemText: 'a',
            pagerLinks: '.pagination li',
            currentNumber: 'span.current-num',
            totalNumber: 'span.total-num',
            btnPlay: '.btn-play',
            btnPause: '.btn-pause',
            btnPlayPause: '.btn-play-pause',
            autorotationActiveClass: 'autorotation-active',
            autorotationDisabledClass: 'autorotation-disabled',
            autorotationStopAfterClick: false,
            circularRotation: true,
            switchSimultaneously: true,
            disableWhileAnimating: false,
            disableFadeIE: false,
            autoRotation: false,
            pauseOnHover: true,
            autoHeight: false,
            switchTime: 4000,
            animSpeed: 600,
            event:'click'
        }, options);
        this.init();
    }
    FadeGallery.prototype = {
        init: function() {
            if(this.options.holder) {
                this.findElements();
                this.initStructure();
                this.attachEvents();
                this.refreshState(true);
                this.autoRotate();
                this.makeCallback('onInit', this);
            }
        },
        findElements: function() {
            // control elements
            this.gallery = $(this.options.holder);
            this.slides = this.gallery.find(this.options.slides);
            this.slidesHolder = this.slides.eq(0).parent();
            this.stepsCount = this.slides.length;
            this.btnPrev = this.gallery.find(this.options.btnPrev);
            this.btnNext = this.gallery.find(this.options.btnNext);
            this.currentIndex = 0;
			
            // disable fade effect in old IE
            if(this.options.disableFadeIE && $.browser.msie && $.browser.version < 9) {
                this.options.animSpeed = 0;
            }
			
            // create gallery pagination
            if(typeof this.options.generatePagination === 'string') {
                this.pagerHolder = this.gallery.find(this.options.generatePagination).empty();
                this.pagerList = $(this.options.pagerList).appendTo(this.pagerHolder);
                for(var i = 0; i < this.stepsCount; i++) {
                    $(this.options.pagerListItem).appendTo(this.pagerList).find(this.options.pagerListItemText).text(i+1);
                }
                this.pagerLinks = this.pagerList.children();
            } else {
                this.pagerLinks = this.gallery.find(this.options.pagerLinks);
            }
			
            // get start index
            var activeSlide = this.slides.filter('.'+this.options.activeClass);
            if(activeSlide.length) {
                this.currentIndex = this.slides.index(activeSlide);
            }
            this.prevIndex = this.currentIndex;
			
            // autorotation control buttons
            this.btnPlay = this.gallery.find(this.options.btnPlay);
            this.btnPause = this.gallery.find(this.options.btnPause);
            this.btnPlayPause = this.gallery.find(this.options.btnPlayPause);
			
            // misc elements
            this.curNum = this.gallery.find(this.options.currentNumber);
            this.allNum = this.gallery.find(this.options.totalNumber);
        },
        initStructure: function() {
            this.slides.css({
                display:'block',
                opacity:0
            }).eq(this.currentIndex).css({
                opacity:''
            });
        },
        attachEvents: function() {
            var self = this;
            this.btnPrev.bind(this.options.event, function(e){
                self.prevSlide();
                if(self.options.autorotationStopAfterClick) {
                    self.stopRotation();
                }
                e.preventDefault();
            });
            this.btnNext.bind(this.options.event, function(e){
                self.nextSlide();
                if(self.options.autorotationStopAfterClick) {
                    self.stopRotation();
                }
                e.preventDefault();
            });
            this.pagerLinks.each(function(ind, obj){
                $(obj).bind(self.options.event, function(e){
                    self.numSlide(ind);
                    if(self.options.autorotationStopAfterClick) {
                        self.stopRotation();
                    }
                    e.preventDefault();
                });
            });
			
            // autorotation buttons handler
            this.btnPlay.bind(this.options.event, function(e){
                self.startRotation();
                e.preventDefault();
            });
            this.btnPause.bind(this.options.event, function(e){
                self.stopRotation();
                e.preventDefault();
            });
            this.btnPlayPause.bind(this.options.event, function(e){
                if(!self.gallery.hasClass(self.options.autorotationActiveClass)) {
                    self.startRotation();
                } else {
                    self.stopRotation();
                }
                e.preventDefault();
            });
			
            // pause on hover handling
            if(this.options.pauseOnHover) {
                this.gallery.hover(function(){
                    if(self.options.autoRotation) {
                        self.galleryHover = true;
                        self.pauseRotation();
                    }
                }, function(){
                    if(self.options.autoRotation) {
                        self.galleryHover = false;
                        self.resumeRotation();
                    }
                });
            }
        },
        prevSlide: function() {
            if(!(this.options.disableWhileAnimating && this.galleryAnimating)) {
                this.prevIndex = this.currentIndex;
                if(this.currentIndex > 0) {
                    this.currentIndex--;
                    this.switchSlide();
                } else if(this.options.circularRotation) {
                    this.currentIndex = this.stepsCount - 1;
                    this.switchSlide();
                }
            }
        },
        nextSlide: function(fromAutoRotation) {
            if(!(this.options.disableWhileAnimating && this.galleryAnimating)) {
                this.prevIndex = this.currentIndex;
                if(this.currentIndex < this.stepsCount - 1) {
                    this.currentIndex++;
                    this.switchSlide();
                } else if(this.options.circularRotation || fromAutoRotation === true) {
                    this.currentIndex = 0;
                    this.switchSlide();
                }
            }
        },
        numSlide: function(c) {
            if(this.currentIndex != c) {
                this.prevIndex = this.currentIndex;
                this.currentIndex = c;
                this.switchSlide();
            }
        },
        switchSlide: function() {
            var self = this;
            if(this.slides.length > 1) {
                this.galleryAnimating = true;
                this.slides.eq(this.prevIndex).stop().animate({
                    opacity:0
                },{
                    duration: this.options.animSpeed,
                    complete: function(){
                        self.slides.eq(self.prevIndex).css({
                            opacity:0
                        });
                    }
                });
                clearTimeout(this.switchTimer);
                this.switchTimer = setTimeout(function(){
                    self.slides.eq(self.currentIndex).stop().animate({
                        opacity:1
                    },{
                        duration: self.options.animSpeed,
                        complete: function(){
                            self.slides.eq(self.currentIndex).css({
                                opacity:''
                            });
                            self.galleryAnimating = false;
                            self.autoRotate();
						
                            // onchange callback
                            self.makeCallback('onChange', self);
                        }
                    });
					
                }, this.options.switchSimultaneously ? 1 : this.options.animSpeed);
                this.refreshState();
				
                // onchange callback
                this.makeCallback('onBeforeChange', this);
            }
        },
        refreshState: function(initial) {
            this.slides.removeClass(this.options.activeClass).eq(this.currentIndex).addClass(this.options.activeClass);
            this.pagerLinks.removeClass(this.options.activeClass).eq(this.currentIndex).addClass(this.options.activeClass);
            this.curNum.html(this.currentIndex+1);
            this.allNum.html(this.stepsCount);
			
            // initial refresh
            if(this.options.autoHeight) {
                if(initial) {
                    this.slidesHolder.css({
                        height: this.slides.eq(this.currentIndex).outerHeight(true)
                    });
                } else {
                    this.slidesHolder.stop().animate({
                        height: this.slides.eq(this.currentIndex).outerHeight(true)
                    }, {
                        duration: this.options.animSpeed
                    });
                }
            }
			
            // disabled state
            if(!this.options.circularRotation) {
                this.btnPrev.add(this.btnNext).removeClass(this.options.disabledClass);
                if(this.currentIndex === 0) this.btnPrev.addClass(this.options.disabledClass);
                if(this.currentIndex === this.stepsCount - 1) this.btnNext.addClass(this.options.disabledClass);
            }
        },
        startRotation: function() {
            this.options.autoRotation = true;
            this.galleryHover = false;
            this.autoRotationStopped = false;
            this.resumeRotation();
        },
        stopRotation: function() {
            this.galleryHover = true;
            this.autoRotationStopped = true;
            this.pauseRotation();
        },
        pauseRotation: function() {
            this.gallery.addClass(this.options.autorotationDisabledClass);
            this.gallery.removeClass(this.options.autorotationActiveClass);
            clearTimeout(this.timer);
        },
        resumeRotation: function() {
            if(!this.autoRotationStopped) {
                this.gallery.addClass(this.options.autorotationActiveClass);
                this.gallery.removeClass(this.options.autorotationDisabledClass);
                this.autoRotate();
            }
        },
        autoRotate: function() {
            var self = this;
            clearTimeout(this.timer);
            if(this.options.autoRotation && !this.galleryHover && !this.autoRotationStopped) {
                this.gallery.addClass(this.options.autorotationActiveClass);
                this.timer = setTimeout(function(){
                    self.nextSlide(true);
                }, this.options.switchTime);
            } else {
                this.pauseRotation();
            }
        },
        makeCallback: function(name) {
            if(typeof this.options[name] === 'function') {
                var args = Array.prototype.slice.call(arguments);
                args.shift();
                this.options[name].apply(this, args);
            }
        }
    }

    // jquery plugin
    $.fn.fadeGallery = function(opt){
        return this.each(function(){
            $(this).data('FadeGallery', new FadeGallery($.extend(opt,{
                holder:this
            })));
        });
    }
}(jQuery));

/*
 * jQuery Carousel plugin
 */
;
(function($){
    function ScrollGallery(options) {
        this.options = $.extend({
            mask: 'div.mask',
            slider: '>*',
            slides: '>*',
            activeClass:'active',
            disabledClass:'disabled',
            btnPrev: 'a.btn-prev',
            btnNext: 'a.btn-next',
            generatePagination: false,
            pagerList: '<ul>',
            pagerListItem: '<li><a href="#"></a></li>',
            pagerListItemText: 'a',
            pagerLinks: '.pagination li',
            currentNumber: 'span.current-num',
            totalNumber: 'span.total-num',
            btnPlay: '.btn-play',
            btnPause: '.btn-pause',
            btnPlayPause: '.btn-play-pause',
            autorotationActiveClass: 'autorotation-active',
            autorotationDisabledClass: 'autorotation-disabled',
            circularRotation: false,
            disableWhileAnimating: false,
            autoRotation: false,
            pauseOnHover: isTouchDevice ? false : true,
            maskAutoSize: false,
            switchTime: 4000,
            animSpeed: 600,
            event:'click',
            swipeGap: false,
            swipeThreshold: 50,
            handleTouch: true,
            vertical: false,
            useTranslate3D: false,
            step: false
        }, options);
        this.init();
    }
    ScrollGallery.prototype = {
        init: function() {
            if(this.options.holder) {
                this.findElements();
                this.attachEvents();
                this.refreshPosition();
                this.refreshState(true);
                this.resumeRotation();
                this.makeCallback('onInit', this);
            }
        },
        findElements: function() {
            // define dimensions proporties
            this.fullSizeFunction = this.options.vertical ? 'outerHeight' : 'outerWidth';
            this.innerSizeFunction = this.options.vertical ? 'height' : 'width';
            this.slideSizeFunction = 'outerHeight';
            this.maskSizeProperty = 'height';
            this.animProperty = this.options.vertical ? 'marginTop' : 'marginLeft';
            this.swipeProperties = this.options.vertical ? ['up', 'down'] : ['left', 'right'];
			
            // control elements
            this.gallery = $(this.options.holder);
            this.mask = this.gallery.find(this.options.mask);
            this.slider = this.mask.find(this.options.slider);
            this.slides = this.slider.find(this.options.slides);
            this.btnPrev = this.gallery.find(this.options.btnPrev);
            this.btnNext = this.gallery.find(this.options.btnNext);
            this.currentStep = 0;
            this.stepsCount = 0;
			
            // get start index
            if(this.options.step === false) {
                var activeSlide = this.slides.filter('.'+this.options.activeClass);
                if(activeSlide.length) {
                    this.currentStep = this.slides.index(activeSlide);
                }
            }
			
            // calculate offsets
            this.calculateOffsets();
            $(window).bind('resize orientationchange', $.proxy(this.onWindowResize, this));
			
            // create gallery pagination
            if(typeof this.options.generatePagination === 'string') {
                this.pagerLinks = $();
                this.buildPagination();
            } else {
                this.pagerLinks = this.gallery.find(this.options.pagerLinks);
                this.attachPaginationEvents();
            }
			
            // autorotation control buttons
            this.btnPlay = this.gallery.find(this.options.btnPlay);
            this.btnPause = this.gallery.find(this.options.btnPause);
            this.btnPlayPause = this.gallery.find(this.options.btnPlayPause);
			
            // misc elements
            this.curNum = this.gallery.find(this.options.currentNumber);
            this.allNum = this.gallery.find(this.options.totalNumber);
        },
        attachEvents: function() {
            this.btnPrev.bind(this.options.event, this.bindScope(function(e){
                this.prevSlide();
                e.preventDefault();
            }));
            this.btnNext.bind(this.options.event, this.bindScope(function(e){
                this.nextSlide();
                e.preventDefault();
            }));
			
            // pause on hover handling
            if(this.options.pauseOnHover) {
                this.gallery.hover(this.bindScope(function(){
                    if(this.options.autoRotation) {
                        this.galleryHover = true;
                        this.pauseRotation();
                    }
                }), this.bindScope(function(){
                    if(this.options.autoRotation) {
                        this.galleryHover = false;
                        this.resumeRotation();
                    }
                }));
            }
			
            // autorotation buttons handler
            this.btnPlay.bind(this.options.event, this.bindScope(this.startRotation));
            this.btnPause.bind(this.options.event, this.bindScope(this.stopRotation));
            this.btnPlayPause.bind(this.options.event, this.bindScope(function(){
                if(!this.gallery.hasClass(this.options.autorotationActiveClass)) {
                    this.startRotation();
                } else {
                    this.stopRotation();
                }
            }));
			
            // swipe event handling
            if(isTouchDevice) {
                // enable hardware acceleration
                if(this.options.useTranslate3D) {
                    this.slider.css({
                        '-webkit-transform': 'translate3d(0px, 0px, 0px)'
                    });
                }
				
                // swipe gestures
                if(this.options.handleTouch && $.fn.swipe) {
                    this.mask.swipe({
                        threshold: this.options.swipeThreshold,
                        allowPageScroll: 'vertical',
                        swipeStatus: $.proxy(function(e, phase, direction, distance) {
                            if(phase === 'start') {
                                this.originalOffset = parseInt(this.slider.stop(true, false).css(this.animProperty));
                            } else if(phase === 'move') {
                                if(direction === this.swipeProperties[0] || direction === this.swipeProperties[1]) {
                                    var tmpOffset = this.originalOffset + distance * (direction === this.swipeProperties[0] ? -1 : 1);
                                    if(!this.options.swipeGap) {
                                        tmpOffset = Math.max(Math.min(0, tmpOffset), this.maxOffset);
                                    }
                                    this.tmpProps = {};
                                    this.tmpProps[this.animProperty] = tmpOffset;
                                    this.slider.css(this.tmpProps);
                                    e.preventDefault();
                                }
                            } else if(phase === 'cancel') {
                                // return to previous position
                                this.switchSlide();
                            }
                        },this),
                        swipe: $.proxy(function(event, direction) {
                            if(direction === this.swipeProperties[0]) {
                                if(this.currentStep === this.stepsCount - 1) this.switchSlide();
                                else this.nextSlide();
                            } else if(direction === this.swipeProperties[1]) {
                                if(this.currentStep === 0) this.switchSlide();
                                else this.prevSlide();
                            }
                        },this)
                    });
                }
            }
        },
        onWindowResize: function() {
            if(!this.galleryAnimating) {
                this.calculateOffsets();
                this.refreshPosition();
                this.buildPagination();
                this.refreshState();
                this.resizeQueue = false;
            } else {
                this.resizeQueue = true;
            }
        },
        refreshPosition: function() {
            this.currentStep = Math.min(this.currentStep, this.stepsCount - 1);
            this.tmpProps = {};
            this.tmpProps[this.animProperty] = this.getStepOffset();
            this.slider.stop().css(this.tmpProps);
        },
        calculateOffsets: function() {
            this.maskSize = this.mask[this.innerSizeFunction]();
            this.sumSize = this.getSumSize();
            this.maxOffset = this.maskSize - this.sumSize;
			
            // vertical gallery with single size step custom behavior
            if(this.options.vertical && this.options.maskAutoSize) {
                this.options.step = 1;
                this.stepsCount = this.slides.length;
                this.stepOffsets = [0];
                var tmpOffset = 0;
                for(var i = 0; i < this.slides.length; i++) {
                    tmpOffset -= $(this.slides[i])[this.fullSizeFunction](true);
                    this.stepOffsets.push(tmpOffset);
                }
                this.maxOffset = tmpOffset;
                return;
            }
			
            // scroll by slide size
            if(typeof this.options.step === 'number' && this.options.step > 0) {
                this.slideDimensions = [];
                this.slides.each($.proxy(function(ind, obj){
                    this.slideDimensions.push( $(obj)[this.fullSizeFunction](true) );
                },this));
				
                // calculate steps count
                this.stepOffsets = [0];
                this.stepsCount = 1;
                var tmpOffset = 0, tmpStep = 0;
                while(tmpOffset > this.maxOffset) {
                    tmpOffset -= this.getSlideSize(tmpStep, tmpStep + this.options.step);
                    tmpStep += this.options.step;
                    this.stepOffsets.push(Math.max(tmpOffset, this.maxOffset));
                    this.stepsCount++;
                }
            }
            // scroll by mask size
            else {
                // define step size
                this.stepSize = this.maskSize;
				
                // calculate steps count
                this.stepsCount = 1;
                var tmpOffset = 0;
                while(tmpOffset > this.maxOffset) {
                    tmpOffset -= this.stepSize;
                    this.stepsCount++;
                }
            }
        },
        getSumSize: function() {
            var sum = 0;
            this.slides.each($.proxy(function(ind, obj){
                sum += $(obj)[this.fullSizeFunction](true);
            },this));
            this.slider.css(this.innerSizeFunction, sum);
            return sum;
        },
        getStepOffset: function(step) {
            step = step || this.currentStep;
            if(typeof this.options.step === 'number') {
                return this.stepOffsets[this.currentStep];
            } else {
                return Math.max(-this.currentStep * this.stepSize, this.maxOffset);
            }
        },
        getSlideSize: function(i1, i2) {
            var sum = 0;
            for(var i = i1; i < Math.min(i2, this.slideDimensions.length); i++) {
                sum += this.slideDimensions[i];
            }
            return sum;
        },
        buildPagination: function() {
            if(typeof this.options.generatePagination === 'string') {
                this.pagerHolder = this.gallery.find(this.options.generatePagination);
                if(this.pagerHolder.length) {
                    this.pagerHolder.empty();
                    this.pagerList = $(this.options.pagerList).appendTo(this.pagerHolder);
                    for(var i = 0; i < this.stepsCount; i++) {
                        $(this.options.pagerListItem).appendTo(this.pagerList).find(this.options.pagerListItemText).text(i+1);
                    }
                    this.pagerLinks = this.pagerList.children();
                    this.attachPaginationEvents();
                }
            }
        },
        attachPaginationEvents: function() {
            this.pagerLinks.each(this.bindScope(function(ind, obj){
                $(obj).bind(this.options.event, this.bindScope(function(){
                    this.numSlide(ind);
                    return false;
                }));
            }));
        },
        prevSlide: function() {
            if(!(this.options.disableWhileAnimating && this.galleryAnimating)) {
                if(this.currentStep > 0) {
                    this.currentStep--;
                    this.switchSlide();
                } else if(this.options.circularRotation) {
                    this.currentStep = this.stepsCount - 1;
                    this.switchSlide();
                }
            }
        },
        nextSlide: function(fromAutoRotation) {
            if(!(this.options.disableWhileAnimating && this.galleryAnimating)) {
                if(this.currentStep < this.stepsCount - 1) {
                    this.currentStep++;
                    this.switchSlide();
                } else if(this.options.circularRotation || fromAutoRotation === true) {
                    this.currentStep = 0;
                    this.switchSlide();
                }
            }
        },
        numSlide: function(c) {
            if(this.currentStep != c) {
                this.currentStep = c;
                this.switchSlide();
            }
        },
        switchSlide: function() {
            this.galleryAnimating = true;
            this.tmpProps = {}
            this.tmpProps[this.animProperty] = this.getStepOffset();
            this.slider.stop().animate(this.tmpProps,{
                duration: this.options.animSpeed,
                complete: this.bindScope(function(){
                    // animation complete
                    this.galleryAnimating = false;
                    if(this.resizeQueue) {
                        this.onWindowResize();
                    }
				
                    // onchange callback
                    this.makeCallback('onChange', this);
                    this.autoRotate();
                })
            });
            this.refreshState();
			
            // onchange callback
            this.makeCallback('onBeforeChange', this);
        },
        refreshState: function(initial) {
            if(this.options.step === 1 || this.stepsCount === this.slides.length) {
                this.slides.removeClass(this.options.activeClass).eq(this.currentStep).addClass(this.options.activeClass);
            }
            this.pagerLinks.removeClass(this.options.activeClass).eq(this.currentStep).addClass(this.options.activeClass);
            this.curNum.html(this.currentStep+1);
            this.allNum.html(this.stepsCount);
			
            // initial refresh
            if(this.options.maskAutoSize && typeof this.options.step === 'number') {
                this.tmpProps = {};
                this.tmpProps[this.maskSizeProperty] = this.slides.eq(Math.min(this.currentStep,this.slides.length-1))[this.slideSizeFunction](true);
                this.mask.stop()[initial ? 'css' : 'animate'](this.tmpProps);
            }
			
            // disabled state
            if(!this.options.circularRotation) {
                this.btnPrev.add(this.btnNext).removeClass(this.options.disabledClass);
                if(this.currentStep === 0) this.btnPrev.addClass(this.options.disabledClass);
                if(this.currentStep === this.stepsCount - 1) this.btnNext.addClass(this.options.disabledClass);
            }
        },
        startRotation: function() {
            this.options.autoRotation = true;
            this.galleryHover = false;
            this.autoRotationStopped = false;
            this.resumeRotation();
        },
        stopRotation: function() {
            this.galleryHover = true;
            this.autoRotationStopped = true;
            this.pauseRotation();
        },
        pauseRotation: function() {
            this.gallery.addClass(this.options.autorotationDisabledClass);
            this.gallery.removeClass(this.options.autorotationActiveClass);
            clearTimeout(this.timer);
        },
        resumeRotation: function() {
            if(!this.autoRotationStopped) {
                this.gallery.addClass(this.options.autorotationActiveClass);
                this.gallery.removeClass(this.options.autorotationDisabledClass);
                this.autoRotate();
            }
        },
        autoRotate: function() {
            clearTimeout(this.timer);
            if(this.options.autoRotation && !this.galleryHover && !this.autoRotationStopped) {
                this.timer = setTimeout(this.bindScope(function(){
                    this.nextSlide(true);
                }), this.options.switchTime);
            } else {
                this.pauseRotation();
            }
        },
        bindScope: function(func, scope) {
            return $.proxy(func, scope || this);
        },
        makeCallback: function(name) {
            if(typeof this.options[name] === 'function') {
                var args = Array.prototype.slice.call(arguments);
                args.shift();
                this.options[name].apply(this, args);
            }
        }
    }
	
    // detect device type
    var isTouchDevice = (function() {
        try {
            return ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch;
        } catch (e) {
            return false;
        }
    }());
	
    // jquery plugin
    $.fn.scrollGallery = function(opt){
        return this.each(function(){
            $(this).data('ScrollGallery', new ScrollGallery($.extend(opt,{
                holder:this
            })));
        });
    }
}(jQuery));

/*
 * touchSwipe - jQuery Plugin
 * http://plugins.jquery.com/project/touchSwipe
 * http://labs.skinkers.com/touchSwipe/
 *
 * Copyright (c) 2010 Matt Bryson (www.skinkers.com)
 * Dual licensed under the MIT or GPL Version 2 licenses.
 *
 * $version: 1.2.5
 */
;
(function(a){
    a.fn.swipe=function(c){
        if(!this){
            return false
        }
        var k={
            fingers:1,
            threshold:75,
            swipe:null,
            swipeLeft:null,
            swipeRight:null,
            swipeUp:null,
            swipeDown:null,
            swipeStatus:null,
            click:null,
            triggerOnTouchEnd:true,
            allowPageScroll:"auto"
        };

        var m="left";
        var l="right";
        var d="up";
        var s="down";
        var j="none";
        var u="horizontal";
        var q="vertical";
        var o="auto";
        var f="start";
        var i="move";
        var h="end";
        var n="cancel";
        var t="ontouchstart" in window,b=t?"touchstart":"mousedown",p=t?"touchmove":"mousemove",g=t?"touchend":"mouseup",r="touchcancel";
        var e="start";
        if(c.allowPageScroll==undefined&&(c.swipe!=undefined||c.swipeStatus!=undefined)){
            c.allowPageScroll=j
        }
        if(c){
            a.extend(k,c)
        }
        return this.each(function(){
            var D=this;
            var H=a(this);
            var E=null;
            var I=0;
            var x={
                x:0,
                y:0
            };

            var A={
                x:0,
                y:0
            };

            var K={
                x:0,
                y:0
            };

            function z(N){
                var M=t?N.touches[0]:N;
                e=f;
                if(t){
                    I=N.touches.length
                }
                distance=0;
                direction=null;
                if(I==k.fingers||!t){
                    x.x=A.x=M.pageX;
                    x.y=A.y=M.pageY;
                    if(k.swipeStatus){
                        y(N,e)
                    }
                }else{
                    C(N)
                }
                D.addEventListener(p,J,false);
                D.addEventListener(g,L,false)
            }
            function J(N){
                if(e==h||e==n){
                    return
                }
                var M=t?N.touches[0]:N;
                A.x=M.pageX;
                A.y=M.pageY;
                direction=v();
                if(t){
                    I=N.touches.length
                }
                e=i;
                G(N,direction);
                if(I==k.fingers||!t){
                    distance=B();
                    if(k.swipeStatus){
                        y(N,e,direction,distance)
                    }
                    if(!k.triggerOnTouchEnd){
                        if(distance>=k.threshold){
                            e=h;
                            y(N,e);
                            C(N)
                        }
                    }
                }else{
                    e=n;
                    y(N,e);
                    C(N)
                }
            }
            function L(M){
                M.preventDefault();
                distance=B();
                direction=v();
                if(k.triggerOnTouchEnd){
                    e=h;
                    if((I==k.fingers||!t)&&A.x!=0){
                        if(distance>=k.threshold){
                            y(M,e);
                            C(M)
                        }else{
                            e=n;
                            y(M,e);
                            C(M)
                        }
                    }else{
                        e=n;
                        y(M,e);
                        C(M)
                    }
                }else{
                    if(e==i){
                        e=n;
                        y(M,e);
                        C(M)
                    }
                }
                D.removeEventListener(p,J,false);
                D.removeEventListener(g,L,false)
            }
            function C(M){
                I=0;
                x.x=0;
                x.y=0;
                A.x=0;
                A.y=0;
                K.x=0;
                K.y=0
            }
            function y(N,M){
                if(k.swipeStatus){
                    k.swipeStatus.call(H,N,M,direction||null,distance||0)
                }
                if(M==n){
                    if(k.click&&(I==1||!t)&&(isNaN(distance)||distance==0)){
                        k.click.call(H,N,N.target)
                    }
                }
                if(M==h){
                    if(k.swipe){
                        k.swipe.call(H,N,direction,distance)
                    }
                    switch(direction){
                        case m:
                            if(k.swipeLeft){
                                k.swipeLeft.call(H,N,direction,distance)
                            }
                            break;
                        case l:
                            if(k.swipeRight){
                                k.swipeRight.call(H,N,direction,distance)
                            }
                            break;
                        case d:
                            if(k.swipeUp){
                                k.swipeUp.call(H,N,direction,distance)
                            }
                            break;
                        case s:
                            if(k.swipeDown){
                                k.swipeDown.call(H,N,direction,distance)
                            }
                            break
                    }
                }
            }
            function G(M,N){
                if(k.allowPageScroll==j){
                    M.preventDefault()
                }else{
                    var O=k.allowPageScroll==o;
                    switch(N){
                        case m:
                            if((k.swipeLeft&&O)||(!O&&k.allowPageScroll!=u)){
                                M.preventDefault()
                            }
                            break;
                        case l:
                            if((k.swipeRight&&O)||(!O&&k.allowPageScroll!=u)){
                                M.preventDefault()
                            }
                            break;
                        case d:
                            if((k.swipeUp&&O)||(!O&&k.allowPageScroll!=q)){
                                M.preventDefault()
                            }
                            break;
                        case s:
                            if((k.swipeDown&&O)||(!O&&k.allowPageScroll!=q)){
                                M.preventDefault()
                            }
                            break
                    }
                }
            }
            function B(){
                return Math.round(Math.sqrt(Math.pow(A.x-x.x,2)+Math.pow(A.y-x.y,2)))
            }
            function w(){
                var P=x.x-A.x;
                var O=A.y-x.y;
                var M=Math.atan2(O,P);
                var N=Math.round(M*180/Math.PI);
                if(N<0){
                    N=360-Math.abs(N)
                }
                return N
            }
            function v(){
                var M=w();
                if((M<=45)&&(M>=0)){
                    return m
                }else{
                    if((M<=360)&&(M>=315)){
                        return m
                    }else{
                        if((M>=135)&&(M<=225)){
                            return l
                        }else{
                            if((M>45)&&(M<135)){
                                return s
                            }else{
                                return d
                            }
                        }
                    }
                }
            }
            try{
                this.addEventListener(b,z,false);
                this.addEventListener(r,C)
            }catch(F){}
        })
    }
})(jQuery);


/* Fancybox overlay fix */
jQuery(function(){
    // detect device type
    var isTouchDevice = (function() {
        try {
            return ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch;
        } catch (e) {
            return false;
        }
    }());

    // fix options
    var supportPositionFixed = !( (jQuery.browser.msie && jQuery.browser.version < 9) || isTouchDevice );
    var overlaySelector = '#fancybox-overlay';
	
    if(supportPositionFixed) {
        // create <style> rules
        var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'),
        rules = document.createTextNode(overlaySelector+'{'+
            'position:fixed;'+
            'top:0;'+
            'left:0;'+
            '}');

        // append style element
        style.type = 'text/css';
        if(style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
    }
});

// clear inputs on focus
function initInputs() {
    PlaceholderInput.replaceByOptions({
        // filter options
        clearInputs: true,
        clearTextareas: true,
        clearPasswords: true,
        skipClass:'default',
        
        // input options
        wrapWithElement:false,
        showUntilTyping:false,
        getParentByClass:false,
        placeholderAttr: 'value'
    });
}

// placeholder class
;
(function(){
    var placeholderCollection = [];
    PlaceholderInput = function() {
        this.options = {
            element:null,
            showUntilTyping:false,
            wrapWithElement:false,
            getParentByClass:false,
            placeholderAttr:'value',
            inputFocusClass:'focus',
            inputActiveClass:'text-active',
            parentFocusClass:'parent-focus',
            parentActiveClass:'parent-active',
            labelFocusClass:'label-focus',
            labelActiveClass:'label-active',
            fakeElementClass:'input-placeholder-text'
        }
        placeholderCollection.push(this);
        this.init.apply(this,arguments);
    }
    PlaceholderInput.refreshAllInputs = function(except) {
        for(var i = 0; i < placeholderCollection.length; i++) {
            if(except !== placeholderCollection[i]) {
                placeholderCollection[i].refreshState();
            }
        }
    }
    PlaceholderInput.replaceByOptions = function(opt) {
        var inputs = [].concat(
            convertToArray(document.getElementsByTagName('input')),
            convertToArray(document.getElementsByTagName('textarea'))
            );
        for(var i = 0; i < inputs.length; i++) {
            if(inputs[i].className.indexOf(opt.skipClass) < 0) {
                var inputType = getInputType(inputs[i]);
                if((opt.clearInputs && (inputType === 'text' || inputType === 'email')) ||
                    (opt.clearTextareas && inputType === 'textarea') || 
                    (opt.clearPasswords && inputType === 'password')
                    ) {
                    new PlaceholderInput({
                        element:inputs[i],
                        wrapWithElement:opt.wrapWithElement,
                        showUntilTyping:opt.showUntilTyping,
                        getParentByClass:opt.getParentByClass,
                        placeholderAttr: inputs[i].getAttribute('placeholder') ? 'placeholder' : opt.placeholderAttr
                    });
                }
            }
        }
    }
    PlaceholderInput.prototype = {
        init: function(opt) {
            this.setOptions(opt);
            if(this.element && this.element.PlaceholderInst) {
                this.element.PlaceholderInst.refreshClasses();
            } else {
                this.element.PlaceholderInst = this;
                if(this.elementType !== 'radio' || this.elementType !== 'checkbox' || this.elementType !== 'file') {
                    this.initElements();
                    this.attachEvents();
                    this.refreshClasses();
                }
            }
        },
        setOptions: function(opt) {
            for(var p in opt) {
                if(opt.hasOwnProperty(p)) {
                    this.options[p] = opt[p];
                }
            }
            if(this.options.element) {
                this.element = this.options.element;
                this.elementType = getInputType(this.element);
                this.wrapWithElement = (this.elementType === 'password' || this.options.showUntilTyping ? true : this.options.wrapWithElement);
                this.setPlaceholderValue(this.options.placeholderAttr);
            }
        },
        setPlaceholderValue: function(attr) {
            this.origValue = (attr === 'value' ? this.element.defaultValue : (this.element.getAttribute(attr) || ''));
            if(this.options.placeholderAttr !== 'value') {
                this.element.removeAttribute(this.options.placeholderAttr);
            }
        },
        initElements: function() {
            // create fake element if needed
            if(this.wrapWithElement) {
                this.fakeElement = document.createElement('span');
                this.fakeElement.className = this.options.fakeElementClass;
                this.fakeElement.innerHTML += this.origValue;
                this.fakeElement.style.color = getStyle(this.element, 'color');
                this.fakeElement.style.position = 'absolute';
                this.element.parentNode.insertBefore(this.fakeElement, this.element);
                
                if(this.element.value === this.origValue || !this.element.value) {
                    this.element.value = '';
                    this.togglePlaceholderText(true);
                } else {
                    this.togglePlaceholderText(false);
                }
            } else if(!this.element.value && this.origValue.length) {
                this.element.value = this.origValue;
            }
            // get input label
            if(this.element.id) {
                this.labels = document.getElementsByTagName('label');
                for(var i = 0; i < this.labels.length; i++) {
                    if(this.labels[i].htmlFor === this.element.id) {
                        this.labelFor = this.labels[i];
                        break;
                    }
                }
            }
            // get parent node (or parentNode by className)
            this.elementParent = this.element.parentNode;
            if(typeof this.options.getParentByClass === 'string') {
                var el = this.element;
                while(el.parentNode) {
                    if(hasClass(el.parentNode, this.options.getParentByClass)) {
                        this.elementParent = el.parentNode;
                        break;
                    } else {
                        el = el.parentNode;
                    }
                }
            }
        },
        attachEvents: function() {
            this.element.onfocus = bindScope(this.focusHandler, this);
            this.element.onblur = bindScope(this.blurHandler, this);
            if(this.options.showUntilTyping) {
                this.element.onkeydown = bindScope(this.typingHandler, this);
                this.element.onpaste = bindScope(this.typingHandler, this);
            }
            if(this.wrapWithElement) this.fakeElement.onclick = bindScope(this.focusSetter, this);
        },
        togglePlaceholderText: function(state) {
            if(this.wrapWithElement) {
                this.fakeElement.style.display = state ? '' : 'none';
            }
            else {
                this.element.value = state ? this.origValue : '';
            }
        },
        focusSetter: function() {
            this.element.focus();
        },
        focusHandler: function() {
            clearInterval(this.checkerInterval);
            this.checkerInterval = setInterval(bindScope(this.intervalHandler,this), 1);
            this.focused = true;
            if(!this.element.value.length || this.element.value === this.origValue) {
                if(!this.options.showUntilTyping) {
                    this.togglePlaceholderText(false);
                }
            }
            this.refreshClasses();
        },
        blurHandler: function() {
            clearInterval(this.checkerInterval);
            this.focused = false;
            if(!this.element.value.length || this.element.value === this.origValue) {
                this.togglePlaceholderText(true);
            }
            this.refreshClasses();
            PlaceholderInput.refreshAllInputs(this);
        },
        typingHandler: function() {
            setTimeout(bindScope(function(){
                if(this.element.value.length) {
                    this.togglePlaceholderText(false);
                    this.refreshClasses();
                }
            },this), 10);
        },
        intervalHandler: function() {
            if(typeof this.tmpValue === 'undefined') {
                this.tmpValue = this.element.value;
            }
            if(this.tmpValue != this.element.value) {
                PlaceholderInput.refreshAllInputs(this);
            }
        },
        refreshState: function() {
            if(this.wrapWithElement) {
                if(this.element.value.length && this.element.value !== this.origValue) {
                    this.togglePlaceholderText(false);
                }
                else if(!this.element.value.length) {
                    this.togglePlaceholderText(true);
                }
            }
            this.refreshClasses();
        },
        refreshClasses: function() {
            this.textActive = this.focused || (this.element.value.length && this.element.value !== this.origValue);
            this.setStateClass(this.element, this.options.inputFocusClass,this.focused);
            this.setStateClass(this.elementParent, this.options.parentFocusClass,this.focused);
            this.setStateClass(this.labelFor, this.options.labelFocusClass,this.focused);
            this.setStateClass(this.element, this.options.inputActiveClass, this.textActive);
            this.setStateClass(this.elementParent, this.options.parentActiveClass, this.textActive);
            this.setStateClass(this.labelFor, this.options.labelActiveClass, this.textActive);
        },
        setStateClass: function(el,cls,state) {
            if(!el) return;
            else if(state) addClass(el,cls); else removeClass(el,cls);
        }
    }
    
    // utility functions
    function convertToArray(collection) {
        var arr = [];
        for (var i = 0, ref = arr.length = collection.length; i < ref; i++) {
            arr[i] = collection[i];
        }
        return arr;
    }
    function getInputType(input) {
        return (input.type ? input.type : input.tagName).toLowerCase();
    }
    function hasClass(el,cls) {
        return el.className ? el.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)')) : false;
    }
    function addClass(el,cls) {
        if (!hasClass(el,cls)) el.className += " "+cls;
    }
    function removeClass(el,cls) {
        if (hasClass(el,cls)) {
            el.className=el.className.replace(new RegExp('(\\s|^)'+cls+'(\\s|$)'),' ');
        }
    }
    function bindScope(f, scope) {
        return function() {
            return f.apply(scope, arguments)
        }
    }
    function getStyle(el, prop) {
        if (document.defaultView && document.defaultView.getComputedStyle) {
            return document.defaultView.getComputedStyle(el, null)[prop];
        } else if (el.currentStyle) {
            return el.currentStyle[prop];
        } else {
            return el.style[prop];
        }
    }
}());

/*
 * JavaScript Custom Forms 1.4.1
 */
jcf = {
    // global options
    modules: {},
    plugins: {},
    baseOptions: {
        useNativeDropOnMobileDevices: true,
        unselectableClass:'jcf-unselectable',
        labelActiveClass:'jcf-label-active',
        labelDisabledClass:'jcf-label-disabled',
        classPrefix: 'jcf-class-',
        hiddenClass:'jcf-hidden',
        focusClass:'jcf-focus',
        wrapperTag: 'div'
    },
    // replacer function
    customForms: {
        setOptions: function(obj) {
            for(var p in obj) {
                if(obj.hasOwnProperty(p) && typeof obj[p] === 'object') {
                    jcf.lib.extend(jcf.modules[p].prototype.defaultOptions, obj[p]);
                }
            }
        },
        replaceAll: function() {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        // refresh form element state
                        els[i].jcf.refreshState();
                    } else {
                        // replace form element
                        if(!jcf.lib.hasClass(els[i], 'default') && jcf.modules[k].prototype.checkElement(els[i])) {
                            new jcf.modules[k]({
                                replaces:els[i]
                            });
                        }
                    }
                }
            }
        },
        refreshAll: function() {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        // refresh form element state
                        els[i].jcf.refreshState();
                    }
                }
            }
        },
        refreshElement: function(obj) {
            if(obj && obj.jcf) {
                obj.jcf.refreshState();
            }
        },
        destroyAll: function() {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        els[i].jcf.destroy();
                    }
                }
            }
        }
    },
    // detect device type
    isTouchDevice: (function() {
        try {
            return ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch;
        } catch (e) {
            return false;
        }
    }()),
    // define base module
    setBaseModule: function(obj) {
        jcf.customControl = function(opt){
            this.options = jcf.lib.extend({}, jcf.baseOptions, this.defaultOptions, opt);
            this.init();
        }
        for(var p in obj) {
            jcf.customControl.prototype[p] = obj[p];
        }
    },
    // add module to jcf.modules
    addModule: function(obj) {
        if(obj.name){
            // create new module proto class
            jcf.modules[obj.name] = function(){
                jcf.modules[obj.name].superclass.constructor.apply(this, arguments);
            }
            jcf.lib.inherit(jcf.modules[obj.name], jcf.customControl);
            for(var p in obj) {
                jcf.modules[obj.name].prototype[p] = obj[p]
            }
            // on create module
            jcf.modules[obj.name].prototype.onCreateModule();
            // make callback for exciting modules
            for(var mod in jcf.modules) {
                if(jcf.modules[mod] != jcf.modules[obj.name]) {
                    jcf.modules[mod].prototype.onModuleAdded(jcf.modules[obj.name]);
                }
            }
        }
    },
    // add plugin to jcf.plugins
    addPlugin: function(obj) {
        if(obj && obj.name) {
            jcf.plugins[obj.name] = function() {
                this.init.apply(this, arguments);
            }
            for(var p in obj) {
                jcf.plugins[obj.name].prototype[p] = obj[p];
            }
        }
    },
    // miscellaneous init
    init: function(){
        this.eventPress = this.isTouchDevice ? 'touchstart' : 'mousedown';
        this.eventMove = this.isTouchDevice ? 'touchmove' : 'mousemove';
        this.eventRelease = this.isTouchDevice ? 'touchend' : 'mouseup';
        return this;
    },
    initStyles: function() {
        // create <style> element and rules
        var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'),
        rules = document.createTextNode('.'+jcf.baseOptions.unselectableClass+'{'+
            '-moz-user-select:none;'+
            '-webkit-tap-highlight-color:rgba(255,255,255,0);'+
            '-webkit-user-select:none;'+
            'user-select:none;'+
            '}');
		
        // append style element
        style.type = 'text/css';
        if(style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
    }
}.init();

/*
 * Custom Form Control prototype
 */
jcf.setBaseModule({
    init: function(){
        if(this.options.replaces) {
            this.realElement = this.options.replaces;
            this.realElement.jcf = this;
            this.replaceObject();
        }
    },
    defaultOptions: {
    // default module options (will be merged with base options)
    },
    checkElement: function(el){
        return true; // additional check for correct form element
    },
    replaceObject: function(){
        this.createWrapper();
        this.attachEvents();
        this.fixStyles();
        this.setupWrapper();
    },
    createWrapper: function(){
        this.fakeElement = jcf.lib.createElement(this.options.wrapperTag);
        this.labelFor = jcf.lib.getLabelFor(this.realElement);
        jcf.lib.disableTextSelection(this.fakeElement);
        jcf.lib.addClass(this.fakeElement, jcf.lib.getAllClasses(this.realElement.className, this.options.classPrefix));
        jcf.lib.addClass(this.realElement, jcf.baseOptions.hiddenClass);
    },
    attachEvents: function(){
        jcf.lib.event.add(this.realElement, 'focus', this.onFocusHandler, this);
        jcf.lib.event.add(this.realElement, 'blur', this.onBlurHandler, this);
        jcf.lib.event.add(this.fakeElement, 'click', this.onFakeClick, this);
        jcf.lib.event.add(this.fakeElement, jcf.eventPress, this.onFakePressed, this);
        jcf.lib.event.add(this.fakeElement, jcf.eventRelease, this.onFakeReleased, this);

        if(this.labelFor) {
            this.labelFor.jcf = this;
            jcf.lib.event.add(this.labelFor, 'click', this.onFakeClick, this);
            jcf.lib.event.add(this.labelFor, jcf.eventPress, this.onFakePressed, this);
            jcf.lib.event.add(this.labelFor, jcf.eventRelease, this.onFakeReleased, this);
        }
    },
    fixStyles: function() {
        // hide mobile webkit tap effect
        if(jcf.isTouchDevice) {
            var tapStyle = 'rgba(255,255,255,0)';
            this.realElement.style.webkitTapHighlightColor = tapStyle;
            this.fakeElement.style.webkitTapHighlightColor = tapStyle;
            if(this.labelFor) {
                this.labelFor.style.webkitTapHighlightColor = tapStyle;
            }
        }
    },
    setupWrapper: function(){
    // implement in subclass
    },
    refreshState: function(){
    // implement in subclass
    },
    destroy: function() {
        if(this.fakeElement && this.fakeElement.parentNode) {
            this.fakeElement.parentNode.removeChild(this.fakeElement);
        }
        jcf.lib.removeClass(this.realElement, jcf.baseOptions.hiddenClass);
        this.realElement.jcf = null;
    },
    onFocus: function(){
        // emulated focus event
        jcf.lib.addClass(this.fakeElement,this.options.focusClass);
    },
    onBlur: function(cb){
        // emulated blur event
        jcf.lib.removeClass(this.fakeElement,this.options.focusClass);
    },
    onFocusHandler: function() {
        // handle focus loses
        if(this.focused) return;
        this.focused = true;
		
        // handle touch devices also
        if(jcf.isTouchDevice) {
            if(jcf.focusedInstance && jcf.focusedInstance.realElement != this.realElement) {
                jcf.focusedInstance.onBlur();
                jcf.focusedInstance.realElement.blur();
            }
            jcf.focusedInstance = this;
        }
        this.onFocus.apply(this, arguments);
    },
    onBlurHandler: function() {
        // handle focus loses
        if(!this.pressedFlag) {
            this.focused = false;
            this.onBlur.apply(this, arguments);
        }
    },
    onFakeClick: function(){
        if(jcf.isTouchDevice) {
            this.onFocus();
        } else if(!this.realElement.disabled) {
            this.realElement.focus();
        }
    },
    onFakePressed: function(e){
        this.pressedFlag = true;
    },
    onFakeReleased: function(){
        this.pressedFlag = false;
    },
    onCreateModule: function(){
    // implement in subclass
    },
    onModuleAdded: function(module) {
    // implement in subclass
    },
    onControlReady: function() {
    // implement in subclass
    }
});

/*
 * JCF Utility Library
 */
jcf.lib = {
    bind: function(func, scope){
        return function() {
            return func.apply(scope, arguments);
        }
    },
    browser: (function() {
        var ua = navigator.userAgent.toLowerCase(), res = {},
        match = /(webkit)[ \/]([\w.]+)/.exec(ua) || /(opera)(?:.*version)?[ \/]([\w.]+)/.exec(ua) ||
        /(msie) ([\w.]+)/.exec(ua) || ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+))?/.exec(ua) || [];
        res[match[1]] = true;
        res.version = match[2] || "0";
        res.safariMac = ua.indexOf('mac') != -1 && ua.indexOf('safari') != -1;
        return res;
    })(),
    getOffset: function (obj) {
        if (obj.getBoundingClientRect) {
            var scrollLeft = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft;
            var scrollTop = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;
            var clientLeft = document.documentElement.clientLeft || document.body.clientLeft || 0;
            var clientTop = document.documentElement.clientTop || document.body.clientTop || 0;
            return {
                top:Math.round(obj.getBoundingClientRect().top + scrollTop - clientTop),
                left:Math.round(obj.getBoundingClientRect().left + scrollLeft - clientLeft)
            }
        }
        else {
            var posLeft = 0, posTop = 0;
            while (obj.offsetParent) {
                posLeft += obj.offsetLeft;
                posTop += obj.offsetTop;
                obj = obj.offsetParent;
            }
            return {
                top:posTop,
                left:posLeft
            };
        }
    },
    getScrollTop: function() {
        return window.pageYOffset || document.documentElement.scrollTop;
    },
    getScrollLeft: function() {
        return window.pageXOffset || document.documentElement.scrollLeft;
    },
    getWindowWidth: function(){
        return document.compatMode=='CSS1Compat' ? document.documentElement.clientWidth : document.body.clientWidth;
    },
    getWindowHeight: function(){
        return document.compatMode=='CSS1Compat' ? document.documentElement.clientHeight : document.body.clientHeight;
    },
    getStyle: function(el, prop) {
        if (document.defaultView && document.defaultView.getComputedStyle) {
            return document.defaultView.getComputedStyle(el, null)[prop];
        } else if (el.currentStyle) {
            return el.currentStyle[prop];
        } else {
            return el.style[prop];
        }
    },
    getParent: function(obj, selector) {
        while(obj.parentNode && obj.parentNode != document.body) {
            if(obj.parentNode.tagName.toLowerCase() == selector.toLowerCase()) {
                return obj.parentNode;
            }
            obj = obj.parentNode;
        }
        return false;
    },
    isParent: function(child, parent) {
        while(child.parentNode) {
            if(child.parentNode === parent) {
                return true;
            }
            child = child.parentNode;
        }
        return false;
    },
    getLabelFor: function(object) {
        if(jcf.lib.getParent(object,'label')) {
            return object.parentNode;
        } else if(object.id) {
            return jcf.lib.queryBySelector('label[for="' + object.id + '"]')[0];
        }
    },
    disableTextSelection: function(el){
        if (typeof el.onselectstart !== 'undefined') {
            el.onselectstart = function() {
                return false
            };
        } else if(window.opera) {
            el.setAttribute('unselectable', 'on');
        } else {
            jcf.lib.addClass(el, jcf.baseOptions.unselectableClass);
        }
    },
    enableTextSelection: function(el) {
        if (typeof el.onselectstart !== 'undefined') {
            el.onselectstart = null;
        } else if(window.opera) {
            el.removeAttribute('unselectable');
        } else {
            jcf.lib.removeClass(el, jcf.baseOptions.unselectableClass);
        }
    },
    queryBySelector: function(selector, scope){
        return this.getElementsBySelector(selector, scope);
    },
    prevSibling: function(node) {
        while(node = node.previousSibling) if(node.nodeType == 1) break;
        return node;
    },
    nextSibling: function(node) {
        while(node = node.nextSibling) if(node.nodeType == 1) break;
        return node;
    },
    fireEvent: function(element,event) {
        if (document.createEventObject){
            var evt = document.createEventObject();
            return element.fireEvent('on'+event,evt)
        }
        else{
            var evt = document.createEvent('HTMLEvents');
            evt.initEvent(event, true, true );
            return !element.dispatchEvent(evt);
        }
    },
    isParent: function(p, c) {
        while(c.parentNode) {
            if(p == c) {
                return true;
            }
            c = c.parentNode;
        }
        return false;
    },
    inherit: function(Child, Parent) {
        var F = function() { }
        F.prototype = Parent.prototype
        Child.prototype = new F()
        Child.prototype.constructor = Child
        Child.superclass = Parent.prototype
    },
    extend: function(obj) {
        for(var i = 1; i < arguments.length; i++) {
            for(var p in arguments[i]) {
                if(arguments[i].hasOwnProperty(p)) {
                    obj[p] = arguments[i][p];
                }
            }
        }
        return obj;
    },
    hasClass: function (obj,cname) {
        return (obj.className ? obj.className.match(new RegExp('(\\s|^)'+cname+'(\\s|$)')) : false);
    },
    addClass: function (obj,cname) {
        if (!this.hasClass(obj,cname)) obj.className += (!obj.className.length || obj.className.charAt(obj.className.length - 1) === ' ' ? '' : ' ') + cname;
    },
    removeClass: function (obj,cname) {
        if (this.hasClass(obj,cname)) obj.className=obj.className.replace(new RegExp('(\\s|^)'+cname+'(\\s|$)'),' ').replace(/\s+$/, '');
    },
    toggleClass: function(obj, cname, condition) {
        if(condition) this.addClass(obj, cname); else this.removeClass(obj, cname);
    },
    createElement: function(tagName, options) {
        var el = document.createElement(tagName);
        for(var p in options) {
            if(options.hasOwnProperty(p)) {
                switch (p) {
                    case 'class':
                        el.className = options[p];
                        break;
                    case 'html':
                        el.innerHTML = options[p];
                        break;
                    case 'style':
                        this.setStyles(el, options[p]);
                        break;
                    default:
                        el.setAttribute(p, options[p]);
                }
            }
        }
        return el;
    },
    setStyles: function(el, styles) {
        for(var p in styles) {
            if(styles.hasOwnProperty(p)) {
                switch (p) {
                    case 'float':
                        el.style.cssFloat = styles[p];
                        break;
                    case 'opacity':
                        el.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity='+styles[p]*100+')';
                        el.style.opacity = styles[p];
                        break;
                    default:
                        el.style[p] = (typeof styles[p] === 'undefined' ? 0 : styles[p]) + (typeof styles[p] === 'number' ? 'px' : '');
                }
            }
        }
        return el;
    },
    getInnerWidth: function(el) {
        return el.offsetWidth - (parseInt(this.getStyle(el,'paddingLeft')) || 0) - (parseInt(this.getStyle(el,'paddingRight')) || 0);
    },
    getInnerHeight: function(el) {
        return el.offsetHeight - (parseInt(this.getStyle(el,'paddingTop')) || 0) - (parseInt(this.getStyle(el,'paddingBottom')) || 0);
    },
    getAllClasses: function(cname, prefix, skip) {
        if(!skip) skip = '';
        if(!prefix) prefix = '';
        return cname ? cname.replace(new RegExp('(\\s|^)'+skip+'(\\s|$)'),' ').replace(/[\s]*([\S]+)+[\s]*/gi,prefix+"$1 ") : '';
    },
    getElementsBySelector: function(selector, scope) {
        if(typeof document.querySelectorAll === 'function') {
            return (scope || document).querySelectorAll(selector);
        }
        var selectors = selector.split(',');
        var resultList = [];
        for(var s = 0; s < selectors.length; s++) {
            var currentContext = [scope || document];
            var tokens = selectors[s].replace(/^\s+/,'').replace(/\s+$/,'').split(' ');
            for (var i = 0; i < tokens.length; i++) {
                token = tokens[i].replace(/^\s+/,'').replace(/\s+$/,'');
                if (token.indexOf('#') > -1) {
                    var bits = token.split('#'), tagName = bits[0], id = bits[1];
                    var element = document.getElementById(id);
                    if (tagName && element.nodeName.toLowerCase() != tagName) {
                        return [];
                    }
                    currentContext = [element];
                    continue;
                }
                if (token.indexOf('.') > -1) {
                    var bits = token.split('.'), tagName = bits[0] || '*', className = bits[1], found = [], foundCount = 0;
                    for (var h = 0; h < currentContext.length; h++) {
                        var elements;
                        if (tagName == '*') {
                            elements = currentContext[h].getElementsByTagName('*');
                        }
                        else {
                            elements = currentContext[h].getElementsByTagName(tagName);
                        }
                        for (var j = 0; j < elements.length; j++) {
                            found[foundCount++] = elements[j];
                        }
                    }
                    currentContext = [];
                    var currentContextIndex = 0;
                    for (var k = 0; k < found.length; k++) {
                        if (found[k].className && found[k].className.match(new RegExp('(\\s|^)'+className+'(\\s|$)'))) {
                            currentContext[currentContextIndex++] = found[k];
                        }
                    }
                    continue;
                }
                if (token.match(/^(\w*)\[(\w+)([=~\|\^\$\*]?)=?"?([^\]"]*)"?\]$/)) {
                    var tagName = RegExp.$1 || '*', attrName = RegExp.$2, attrOperator = RegExp.$3, attrValue = RegExp.$4;
                    if(attrName.toLowerCase() == 'for' && this.browser.msie && this.browser.version < 8) {
                        attrName = 'htmlFor';
                    }
                    var found = [], foundCount = 0;
                    for (var h = 0; h < currentContext.length; h++) {
                        var elements;
                        if (tagName == '*') {
                            elements = currentContext[h].getElementsByTagName('*');
                        } else {
                            elements = currentContext[h].getElementsByTagName(tagName);
                        }
                        for (var j = 0; elements[j]; j++) {
                            found[foundCount++] = elements[j];
                        }
                    }
                    currentContext = [];
                    var currentContextIndex = 0, checkFunction;
                    switch (attrOperator) {
                        case '=':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName) == attrValue)
                            };
                            break;
                        case '~':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName).match(new RegExp('(\\s|^)'+attrValue+'(\\s|$)')))
                            };
                            break;
                        case '|':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName).match(new RegExp('^'+attrValue+'-?')))
                            };
                            break;
                        case '^':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName).indexOf(attrValue) == 0)
                            };
                            break;
                        case '$':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName).lastIndexOf(attrValue) == e.getAttribute(attrName).length - attrValue.length)
                            };
                            break;
                        case '*':
                            checkFunction = function(e) {
                                return (e.getAttribute(attrName).indexOf(attrValue) > -1)
                            };
                            break;
                        default :
                            checkFunction = function(e) {
                                return e.getAttribute(attrName)
                            };
                    }
                    currentContext = [];
                    var currentContextIndex = 0;
                    for (var k = 0; k < found.length; k++) {
                        if (checkFunction(found[k])) {
                            currentContext[currentContextIndex++] = found[k];
                        }
                    }
                    continue;
                }
                tagName = token;
                var found = [], foundCount = 0;
                for (var h = 0; h < currentContext.length; h++) {
                    var elements = currentContext[h].getElementsByTagName(tagName);
                    for (var j = 0; j < elements.length; j++) {
                        found[foundCount++] = elements[j];
                    }
                }
                currentContext = found;
            }
            resultList = [].concat(resultList,currentContext);
        }
        return resultList;
    },
    scrollSize: (function(){
        var content, hold, sizeBefore, sizeAfter;
        function buildSizer(){
            if(hold) removeSizer();
            content = document.createElement('div');
            hold = document.createElement('div');
            hold.style.cssText = 'position:absolute;overflow:hidden;width:100px;height:100px';
            hold.appendChild(content);
            document.body.appendChild(hold);
        }
        function removeSizer(){
            document.body.removeChild(hold);
            hold = null;
        }
        function calcSize(vertical) {
            buildSizer();
            content.style.cssText = 'height:'+(vertical ? '100%' : '200px');
            sizeBefore = (vertical ? content.offsetHeight : content.offsetWidth);
            hold.style.overflow = 'scroll';
            content.innerHTML = 1;
            sizeAfter = (vertical ? content.offsetHeight : content.offsetWidth);
            if(vertical && hold.clientHeight) sizeAfter = hold.clientHeight;
            removeSizer();
            return sizeBefore - sizeAfter;
        }
        return {
            getWidth:function(){
                return calcSize(false);
            },
            getHeight:function(){
                return calcSize(true)
            }
        }
    }()),
    domReady: function (handler){
        var called = false
        function ready() {
            if (called) return;
            called = true;
            handler();
        }
        if (document.addEventListener) {
            document.addEventListener("DOMContentLoaded", ready, false);
        }
        else if (document.attachEvent) {
            if (document.documentElement.doScroll && window == window.top) {
                function tryScroll(){
                    if (called) return
                    if (!document.body) return
                    try {
                        document.documentElement.doScroll("left")
                        ready()
                    } catch(e) {
                        setTimeout(tryScroll, 0)
                    }
                }
                tryScroll()
            }
            document.attachEvent("onreadystatechange", function(){
                if (document.readyState === "complete") {
                    ready()
                }
            })
        }
        if (window.addEventListener) window.addEventListener('load', ready, false)
        else if (window.attachEvent) window.attachEvent('onload', ready)
    },
    event: (function(){
        var guid = 0;
        function fixEvent(e) {
            e = e || window.event;
            if (e.isFixed) {
                return e;
            }
            e.isFixed = true;
            e.preventDefault = e.preventDefault || function(){
                this.returnValue = false
            }
            e.stopPropagation = e.stopPropagaton || function(){
                this.cancelBubble = true
            }
            if (!e.target) {
                e.target = e.srcElement
            }
            if (!e.relatedTarget && e.fromElement) {
                e.relatedTarget = e.fromElement == e.target ? e.toElement : e.fromElement;
            }
            if (e.pageX == null && e.clientX != null) {
                var html = document.documentElement, body = document.body;
                e.pageX = e.clientX + (html && html.scrollLeft || body && body.scrollLeft || 0) - (html.clientLeft || 0);
                e.pageY = e.clientY + (html && html.scrollTop || body && body.scrollTop || 0) - (html.clientTop || 0);
            }
            if (!e.which && e.button) {
                e.which = e.button & 1 ? 1 : (e.button & 2 ? 3 : (e.button & 4 ? 2 : 0));
            }
            if(e.type === "DOMMouseScroll" || e.type === 'mousewheel') {
                e.mWheelDelta = 0;
                if (e.wheelDelta) {
                    e.mWheelDelta = e.wheelDelta/120;
                } else if (e.detail) {
                    e.mWheelDelta = -e.detail/3;
                }
            }
            return e;
        }
        function commonHandle(event, customScope) {
            event = fixEvent(event);
            var handlers = this.events[event.type];
            for (var g in handlers) {
                var handler = handlers[g];
                var ret = handler.call(customScope || this, event);
                if (ret === false) {
                    event.preventDefault()
                    event.stopPropagation()
                }
            }
        }
        var publicAPI = {
            add: function(elem, type, handler, forcedScope) {
                if (elem.setInterval && (elem != window && !elem.frameElement)) {
                    elem = window;
                }
                if (!handler.guid) {
                    handler.guid = ++guid;
                }
                if (!elem.events) {
                    elem.events = {};
                    elem.handle = function(event) {
                        return commonHandle.call(elem, event);
                    }
                }
                if (!elem.events[type]) {
                    elem.events[type] = {};
                    if (elem.addEventListener) elem.addEventListener(type, elem.handle, false);
                    else if (elem.attachEvent) elem.attachEvent("on" + type, elem.handle);
                    if(type === 'mousewheel') {
                        publicAPI.add(elem, 'DOMMouseScroll', handler, forcedScope);
                    }
                }
                var fakeHandler = jcf.lib.bind(handler, forcedScope);
                fakeHandler.guid = handler.guid;
                elem.events[type][handler.guid] = forcedScope ? fakeHandler : handler;
            },
            remove: function(elem, type, handler) {
                var handlers = elem.events && elem.events[type];
                if (!handlers) return;
                delete handlers[handler.guid];
                for(var any in handlers) return;
                if (elem.removeEventListener) elem.removeEventListener(type, elem.handle, false);
                else if (elem.detachEvent) elem.detachEvent("on" + type, elem.handle);
                delete elem.events[type];
                for (var any in elem.events) return;
                try {
                    delete elem.handle;
                    delete elem.events;
                } catch(e) {
                    if(elem.removeAttribute) {
                        elem.removeAttribute("handle");
                        elem.removeAttribute("events");
                    }
                }
                if(type === 'mousewheel') {
                    publicAPI.remove(elem, 'DOMMouseScroll', handler);
                }
            }
        }
        return publicAPI;
    }())
}

// init jcf styles
jcf.lib.domReady(function(){
    jcf.initStyles();
});

// custom checkbox module
jcf.addModule({
    name:'checkbox',
    selector:'input[type="checkbox"]',
    defaultOptions: {
        wrapperClass:'chk-area',
        focusClass:'chk-focus',
        checkedClass:'chk-checked',
        labelActiveClass:'chk-label-active',
        uncheckedClass:'chk-unchecked',
        disabledClass:'chk-disabled',
        chkStructure:'<span></span>'
    },
    setupWrapper: function(){
        jcf.lib.addClass(this.fakeElement, this.options.wrapperClass);
        this.fakeElement.innerHTML = this.options.chkStructure;
        this.realElement.parentNode.insertBefore(this.fakeElement, this.realElement);
        jcf.lib.event.add(this.realElement, 'click', this.onRealClick, this);
        this.refreshState();
    },
    onFakePressed: function() {
        jcf.modules[this.name].superclass.onFakePressed.apply(this, arguments);
        if(!this.realElement.disabled) {
            this.realElement.focus();
        }
    },
    onFakeClick: function(e) {
        jcf.modules[this.name].superclass.onFakeClick.apply(this, arguments);
        this.tmpTimer = setTimeout(jcf.lib.bind(function(){
            this.toggle();
        },this),10);
        return false;
    },
    onRealClick: function(e) {
        setTimeout(jcf.lib.bind(function(){
            this.refreshState();
        },this),10);
        e.stopPropagation();
    },
    toggle: function(e){
        if(!this.realElement.disabled) {
            if(this.realElement.checked) {
                this.realElement.checked = false;
            } else {
                this.realElement.checked = true;
            }
        }
        this.refreshState();
        return false;
    },
    refreshState: function(){
        if(this.realElement.checked) {
            jcf.lib.addClass(this.fakeElement, this.options.checkedClass);
            jcf.lib.removeClass(this.fakeElement, this.options.uncheckedClass);
            if(this.labelFor) {
                jcf.lib.addClass(this.labelFor, this.options.labelActiveClass);
            }
        } else {
            jcf.lib.removeClass(this.fakeElement, this.options.checkedClass);
            jcf.lib.addClass(this.fakeElement, this.options.uncheckedClass);
            if(this.labelFor) {
                jcf.lib.removeClass(this.labelFor, this.options.labelActiveClass);
            }
        }
        if(this.realElement.disabled) {
            jcf.lib.addClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.addClass(this.labelFor, this.options.labelDisabledClass);
            }
        } else {
            jcf.lib.removeClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.removeClass(this.labelFor, this.options.labelDisabledClass);
            }
        }
    }
});

// custom select module
jcf.addModule({
    name:'select',
    selector:'select',
    defaultOptions: {
        hideDropOnScroll: true,
        showNativeDrop: false,
        handleDropPosition: true,
        selectDropPosition: 'bottom', // or 'top'
        wrapperClass:'select-area',
        focusClass:'select-focus',
        dropActiveClass:'select-active',
        selectedClass:'item-selected',
        currentSelectedClass:'current-selected',
        disabledClass:'select-disabled',
        valueSelector:'span.center',
        optGroupClass:'optgroup',
        openerSelector:'a.select-opener',
        selectStructure:'<span class="left"></span><span class="center"></span><a class="select-opener"></a>',
        classPrefix:'select-',
        dropMaxHeight: 200,
        dropFlippedClass: 'select-options-flipped',
        dropHiddenClass:'options-hidden',
        dropScrollableClass:'options-overflow',
        dropClass:'select-options',
        dropClassPrefix:'drop-',
        dropStructure:'<div class="drop-holder"><div class="drop-list"></div></div>',
        dropSelector:'div.drop-list'
    },
    checkElement: function(el){
        return (!el.size && !el.multiple);
    },
    setupWrapper: function(){
        jcf.lib.addClass(this.fakeElement, this.options.wrapperClass);
        this.realElement.parentNode.insertBefore(this.fakeElement, this.realElement);
        this.fakeElement.innerHTML = this.options.selectStructure;
        this.fakeElement.style.width = (this.realElement.offsetWidth > 0 ? this.realElement.offsetWidth + 'px' : 'auto');

        // show native drop if specified in options
        if(jcf.isTouchDevice && jcf.baseOptions.useNativeDropOnMobileDevices) {
            this.options.showNativeDrop = true;
        }
        if(this.options.showNativeDrop) {
            this.fakeElement.appendChild(this.realElement);
            jcf.lib.removeClass(this.realElement, this.options.hiddenClass);
            jcf.lib.setStyles(this.realElement, {
                top:0,
                left:0,
                margin:0,
                padding:0,
                opacity:0,
                border:'none',
                position:'absolute',
                width: jcf.lib.getInnerWidth(this.fakeElement) - 1,
                height: jcf.lib.getInnerHeight(this.fakeElement) - 1
            });
        }
		
        // create select body
        this.opener = jcf.lib.queryBySelector(this.options.openerSelector, this.fakeElement)[0];
        this.valueText = jcf.lib.queryBySelector(this.options.valueSelector, this.fakeElement)[0];
        jcf.lib.disableTextSelection(this.valueText);
        this.opener.jcf = this;

        if(!this.options.showNativeDrop) {
            this.createDropdown();
            this.refreshState();
            this.onControlReady(this);
            this.hideDropdown(true);
        } else {
            this.refreshState();
        }
        this.addEvents();
    },
    addEvents: function(){
        if(this.options.showNativeDrop) {
            jcf.lib.event.add(this.realElement, 'click', this.onChange, this);
        } else {
            jcf.lib.event.add(this.fakeElement, 'click', this.toggleDropdown, this);
        }
        jcf.lib.event.add(this.realElement, 'change', this.onChange, this);
    },
    onFakeClick: function() {
    // do nothing (drop toggles by toggleDropdown method)
    },
    onFocus: function(){
        jcf.modules[this.name].superclass.onFocus.apply(this, arguments);
        if(!this.options.showNativeDrop) {
            // Mac Safari Fix
            if(jcf.lib.browser.safariMac) {
                this.realElement.setAttribute('size','2');
            }
            jcf.lib.event.add(this.realElement, 'keydown', this.onKeyDown, this);
            if(jcf.activeControl && jcf.activeControl != this) {
                jcf.activeControl.hideDropdown();
                jcf.activeControl = this;
            }
        }
    },
    onBlur: function(){
        if(!this.options.showNativeDrop) {
            // Mac Safari Fix
            if(jcf.lib.browser.safariMac) {
                this.realElement.removeAttribute('size');
            }
            if(!this.isActiveDrop() || !this.isOverDrop()) {
                jcf.modules[this.name].superclass.onBlur.apply(this);
                if(jcf.activeControl === this) jcf.activeControl = null;
                if(!jcf.isTouchDevice) {
                    this.hideDropdown();
                }
            }
            jcf.lib.event.remove(this.realElement, 'keydown', this.onKeyDown);
        } else {
            jcf.modules[this.name].superclass.onBlur.apply(this);
        }
    },
    onChange: function() {
        this.refreshState();
    },
    onKeyDown: function(e){
        jcf.tmpFlag = true;
        setTimeout(function(){
            jcf.tmpFlag = false
        },100);
        var context = this;
        context.keyboardFix = true;
        setTimeout(function(){
            context.refreshState();
        },10);
        if(e.keyCode == 13) {
            context.toggleDropdown.apply(context);
            return false;
        }
    },
    onResizeWindow: function(e){
        if(this.isActiveDrop()) {
            this.hideDropdown();
        }
    },
    onScrollWindow: function(e){
        if(this.options.hideDropOnScroll) {
            this.hideDropdown();
        } else if(this.isActiveDrop()) {
            this.positionDropdown();
        }
    },
    onOptionClick: function(e){
        var opener = e.target && e.target.tagName && e.target.tagName.toLowerCase() == 'li' ? e.target : jcf.lib.getParent(e.target, 'li');
        if(opener) {
            this.realElement.selectedIndex = parseInt(opener.getAttribute('rel'));
            if(jcf.isTouchDevice) {
                this.onFocus();
            } else {
                this.realElement.focus();
            }
            this.refreshState();
            this.hideDropdown();
            jcf.lib.fireEvent(this.realElement, 'change');
        }
        return false;
    },
    onClickOutside: function(e){
        if(jcf.tmpFlag) {
            jcf.tmpFlag = false;
            return;
        }
        if(!jcf.lib.isParent(this.fakeElement, e.target) && !jcf.lib.isParent(this.selectDrop, e.target)) {
            this.hideDropdown();
        }
    },
    onDropHover: function(e){
        if(!this.keyboardFix) {
            this.hoverFlag = true;
            var opener = e.target && e.target.tagName && e.target.tagName.toLowerCase() == 'li' ? e.target : jcf.lib.getParent(e.target, 'li');
            if(opener) {
                this.realElement.selectedIndex = parseInt(opener.getAttribute('rel'));
                this.refreshSelectedClass(parseInt(opener.getAttribute('rel')));
            }
        } else {
            this.keyboardFix = false;
        }
    },
    onDropLeave: function(){
        this.hoverFlag = false;
    },
    isActiveDrop: function(){
        return !jcf.lib.hasClass(this.selectDrop, this.options.dropHiddenClass);
    },
    isOverDrop: function(){
        return this.hoverFlag;
    },
    createDropdown: function(){
        // remove old dropdown if exists
        if(this.selectDrop) {
            this.selectDrop.parentNode.removeChild(this.selectDrop);
        }

        // create dropdown holder
        this.selectDrop = document.createElement('div');
        this.selectDrop.className = this.options.dropClass;
        this.selectDrop.innerHTML = this.options.dropStructure;
        jcf.lib.setStyles(this.selectDrop, {
            position:'absolute'
        });
        this.selectList = jcf.lib.queryBySelector(this.options.dropSelector,this.selectDrop)[0];
        jcf.lib.addClass(this.selectDrop, this.options.dropHiddenClass);
        document.body.appendChild(this.selectDrop);
        this.selectDrop.jcf = this;
        jcf.lib.event.add(this.selectDrop, 'click', this.onOptionClick, this);
        jcf.lib.event.add(this.selectDrop, 'mouseover', this.onDropHover, this);
        jcf.lib.event.add(this.selectDrop, 'mouseout', this.onDropLeave, this);
        this.buildDropdown();
    },
    buildDropdown: function() {
        // build select options / optgroups
        this.buildDropdownOptions();

        // position and resize dropdown
        this.positionDropdown();

        // cut dropdown if height exceedes
        this.buildDropdownScroll();
    },
    buildDropdownOptions: function() {
        this.resStructure = '';
        this.optNum = 0;
        for(var i = 0; i < this.realElement.children.length; i++) {
            this.resStructure += this.buildElement(this.realElement.children[i]) +'\n';
        }
        this.selectList.innerHTML = this.resStructure;
    },
    buildDropdownScroll: function() {
        if(this.options.dropMaxHeight) {
            if(this.selectDrop.offsetHeight > this.options.dropMaxHeight) {
                this.selectList.style.height = this.options.dropMaxHeight+'px';
                this.selectList.style.overflow = 'auto';
                this.selectList.style.overflowX = 'hidden';
                jcf.lib.addClass(this.selectDrop, this.options.dropScrollableClass);
            }
        }
        jcf.lib.addClass(this.selectDrop, jcf.lib.getAllClasses(this.realElement.className, this.options.dropClassPrefix, jcf.baseOptions.hiddenClass));
    },
    parseOptionTitle: function(optTitle) {
        return (typeof optTitle === 'string' && /\.(jpg|gif|png|bmp|jpeg)(.*)?$/i.test(optTitle)) ? optTitle : '';
    },
    buildElement: function(obj){
        // build option
        var res = '', optImage;
        if(obj.tagName.toLowerCase() == 'option') {
            if(!jcf.lib.prevSibling(obj) || jcf.lib.prevSibling(obj).tagName.toLowerCase() != 'option') {
                res += '<ul>';
            }
			
            optImage = this.parseOptionTitle(obj.title);
            res += '<li rel="'+(this.optNum++)+'" class="'+(obj.className? obj.className + ' ' : '')+'jcfcalc"><a href="#">'+(optImage ? '<img src="'+optImage+'" alt="" />' : '')+'<span>' + obj.innerHTML + '</span></a></li>';
            if(!jcf.lib.nextSibling(obj) || jcf.lib.nextSibling(obj).tagName.toLowerCase() != 'option') {
                res += '</ul>';
            }
            return res;
        }
        // build option group with options
        else if(obj.tagName.toLowerCase() == 'optgroup' && obj.label) {
            res += '<div class="'+this.options.optGroupClass+'">';
            res += '<strong class="jcfcalc"><em>'+(obj.label)+'</em></strong>';
            for(var i = 0; i < obj.children.length; i++) {
                res += this.buildElement(obj.children[i]);
            }
            res += '</div>';
            return res;
        }
    },
    positionDropdown: function(){
        var ofs = jcf.lib.getOffset(this.fakeElement), selectAreaHeight = this.fakeElement.offsetHeight, selectDropHeight = this.selectDrop.offsetHeight;
        var fitInTop = ofs.top - selectDropHeight >= jcf.lib.getScrollTop() && jcf.lib.getScrollTop() + jcf.lib.getWindowHeight() < ofs.top + selectAreaHeight + selectDropHeight;
		
		
        if((this.options.handleDropPosition && fitInTop) || this.options.selectDropPosition === 'top') {
            this.selectDrop.style.top = (ofs.top - selectDropHeight)+'px';
            jcf.lib.addClass(this.selectDrop, this.options.dropFlippedClass);
        } else {
            this.selectDrop.style.top = (ofs.top + selectAreaHeight)+'px';
            jcf.lib.removeClass(this.selectDrop, this.options.dropFlippedClass);
        }
        this.selectDrop.style.left = ofs.left+'px';
        this.selectDrop.style.width = this.fakeElement.offsetWidth+'px';
    },
    showDropdown: function(){
        document.body.appendChild(this.selectDrop);
        jcf.lib.removeClass(this.selectDrop, this.options.dropHiddenClass);
        jcf.lib.addClass(this.fakeElement,this.options.dropActiveClass);
        this.positionDropdown();

        // highlight current active item
        var activeItem = this.getFakeActiveOption();
        this.removeClassFromItems(this.options.currentSelectedClass);
        jcf.lib.addClass(activeItem, this.options.currentSelectedClass);
		
        // show current dropdown
        jcf.lib.event.add(window, 'resize', this.onResizeWindow, this);
        jcf.lib.event.add(window, 'scroll', this.onScrollWindow, this);
        jcf.lib.event.add(document, jcf.eventPress, this.onClickOutside, this);
        this.positionDropdown();
    },
    hideDropdown: function(partial){
        if(this.selectDrop.parentNode) {
            if(this.selectDrop.offsetWidth) {
                this.selectDrop.parentNode.removeChild(this.selectDrop);
            }
            if(partial) {
                return;
            }
        }
        if(typeof this.origSelectedIndex === 'number') {
            this.realElement.selectedIndex = this.origSelectedIndex;
        }
        jcf.lib.removeClass(this.fakeElement,this.options.dropActiveClass);
        jcf.lib.addClass(this.selectDrop, this.options.dropHiddenClass);
        jcf.lib.event.remove(window, 'resize', this.onResizeWindow);
        jcf.lib.event.remove(window, 'scroll', this.onScrollWindow);
        jcf.lib.event.remove(document.documentElement, jcf.eventPress, this.onClickOutside);
        if(jcf.isTouchDevice) {
            this.onBlur();
        }
    },
    toggleDropdown: function(){
        if(!this.realElement.disabled) {
            if(jcf.isTouchDevice) {
                this.onFocus();
            } else {
                this.realElement.focus();
            }
            this.dropOpened = true;
            if(this.isActiveDrop()) {
                this.hideDropdown();
            } else {
                this.showDropdown();
            }
            this.refreshState();
        }
    },
    scrollToItem: function(){
        if(this.isActiveDrop()) {
            var dropHeight = this.selectList.offsetHeight;
            var offsetTop = this.calcOptionOffset(this.getFakeActiveOption());
            var sTop = this.selectList.scrollTop;
            var oHeight = this.getFakeActiveOption().offsetHeight;
            //offsetTop+=sTop;

            if(offsetTop >= sTop + dropHeight) {
                this.selectList.scrollTop = offsetTop - dropHeight + oHeight;
            }
            else if(offsetTop < sTop) {
                this.selectList.scrollTop = offsetTop;
            }
        }
    },
    getFakeActiveOption: function(c) {
        return jcf.lib.queryBySelector('li[rel="'+(typeof c === 'number' ? c : this.realElement.selectedIndex) +'"]',this.selectList)[0];
    },
    calcOptionOffset: function(fake) {
        var h = 0;
        var els = jcf.lib.queryBySelector('.jcfcalc',this.selectList);
        for(var i = 0; i < els.length; i++) {
            if(els[i] == fake) break;
            h+=els[i].offsetHeight;
        }
        return h;
    },
    childrenHasItem: function(hold,item) {
        var items = hold.getElementsByTagName('*');
        for(i = 0; i < items.length; i++) {
            if(items[i] == item) return true;
        }
        return false;
    },
    removeClassFromItems: function(className){
        var children = jcf.lib.queryBySelector('li',this.selectList);
        for(var i = children.length - 1; i >= 0; i--) {
            jcf.lib.removeClass(children[i], className);
        }
    },
    setSelectedClass: function(c){
        jcf.lib.addClass(this.getFakeActiveOption(c), this.options.selectedClass);
    },
    refreshSelectedClass: function(c){
        if(!this.options.showNativeDrop) {
            this.removeClassFromItems(this.options.selectedClass);
            this.setSelectedClass(c);
        }
        if(this.realElement.disabled) {
            jcf.lib.addClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.addClass(this.labelFor, this.options.labelDisabledClass);
            }
        } else {
            jcf.lib.removeClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.removeClass(this.labelFor, this.options.labelDisabledClass);
            }
        }
    },
    refreshSelectedText: function() {
        if(!this.dropOpened && this.realElement.title) {
            this.valueText.innerHTML = this.realElement.title;
        } else {
            if(this.realElement.options[this.realElement.selectedIndex].title) {
                var optImage = this.parseOptionTitle(this.realElement.options[this.realElement.selectedIndex].title);
                this.valueText.innerHTML = (optImage ? '<img src="'+optImage+'" alt="" />' : '') + this.realElement.options[this.realElement.selectedIndex].innerHTML;
            } else {
                this.valueText.innerHTML = this.realElement.options[this.realElement.selectedIndex].innerHTML;
            }
        }
    },
    refreshState: function(){
        this.origSelectedIndex = this.realElement.selectedIndex;
        this.refreshSelectedClass();
        this.refreshSelectedText();
        if(!this.options.showNativeDrop) {
            this.positionDropdown();
            if(this.selectDrop.offsetWidth) {
                this.scrollToItem();
            }
        }
    }
});

// custom upload field module
jcf.addModule({
    name: 'file',
    selector: 'input[type="file"]',
    defaultOptions: {
        buttonWidth: 30,
        bigFontSize: 200,
        buttonText:'Browse',
        wrapperClass:'file-area',
        focusClass:'file-focus',
        disabledClass:'file-disabled',
        opacityClass:'file-input-opacity',
        noFileClass:'no-file',
        extPrefixClass:'extension-',
        uploadStructure:'<div class="jcf-input-wrapper"><div class="jcf-wrap"></div><label class="jcf-fake-input"><span><em></em></span></label><a class="jcf-upload-button"><span></span></a></div>',
        uploadFileNameSelector:'label.jcf-fake-input span em',
        uploadButtonSelector:'a.jcf-upload-button span',
        inputWrapper: 'div.jcf-wrap'
    },
    setupWrapper: function(){
        jcf.lib.addClass(this.fakeElement, this.options.wrapperClass);
        this.fakeElement.innerHTML = this.options.uploadStructure;
        this.realElement.parentNode.insertBefore(this.fakeElement, this.realElement);
        this.fileNameInput = jcf.lib.queryBySelector(this.options.uploadFileNameSelector ,this.fakeElement)[0];
        this.uploadButton = jcf.lib.queryBySelector(this.options.uploadButtonSelector ,this.fakeElement)[0];
        this.inputWrapper = jcf.lib.queryBySelector(this.options.inputWrapper ,this.fakeElement)[0];

        this.origTitle = this.realElement.title;
        this.fileNameInput.innerHTML = this.realElement.title || '';
        this.uploadButton.innerHTML = this.options.buttonText;
        this.realElement.removeAttribute('title');
        this.fakeElement.style.position = 'relative';
        this.realElement.style.position = 'absolute';
        this.realElement.style.zIndex = 100;
        this.inputWrapper.appendChild(this.realElement);
        this.oTop = this.oLeft = this.oWidth = this.oHeight = 0;

        jcf.lib.addClass(this.realElement, this.options.opacityClass);
        jcf.lib.removeClass(this.realElement, jcf.baseOptions.hiddenClass);
        this.inputWrapper.style.width = this.inputWrapper.parentNode.offsetWidth+'px';

        this.shakeInput();
        this.refreshState();
        this.addEvents();
    },
    addEvents: function(){
        jcf.lib.event.add(this.realElement, 'change', this.onChange, this);
        if(!jcf.isTouchDevice) {
            jcf.lib.event.add(this.fakeElement, 'mousemove', this.onMouseMove, this);
            jcf.lib.event.add(this.fakeElement, 'mouseover', this.recalcDimensions, this);
        }
    },
    onMouseMove: function(e){
        this.realElement.style.top = Math.round(e.pageY - this.oTop - this.oHeight/2) + 'px';
        this.realElement.style.left = (e.pageX - this.oLeft - this.oWidth + this.options.buttonWidth) + 'px';
    },
    onChange: function(){
        this.refreshState();
    },
    getFileName: function(){
        return this.realElement.value.replace(/^[\s\S]*(?:\\|\/)([\s\S^\\\/]*)$/g, "$1");
    },
    getFileExtension: function(){
        return this.realElement.value.lastIndexOf('.') < 0 ? false : this.realElement.value.substring(this.realElement.value.lastIndexOf('.')+1).toLowerCase();
    },
    updateExtensionClass: function(){
        var currentExtension = this.getFileExtension();
        if(currentExtension) {
            this.fakeElement.className = this.fakeElement.className.replace(new RegExp('(\\s|^)'+this.options.extPrefixClass+'[^ ]+','gi'),'')
            jcf.lib.addClass(this.fakeElement, this.options.extPrefixClass+currentExtension)
        }
    },
    shakeInput: function() {
        // make input bigger
        jcf.lib.setStyles(this.realElement, {
            fontSize: this.options.bigFontSize,
            lineHeight: this.options.bigFontSize,
            heigth: 'auto',
            top: 0,
            left: this.inputWrapper.offsetWidth - this.realElement.offsetWidth
        });
        // IE styling fix
        if((/(MSIE)/gi).test(navigator.userAgent)) {
            this.tmpElement = document.createElement('span');
            this.inputWrapper.insertBefore(this.tmpElement,this.realElement);
            this.inputWrapper.insertBefore(this.realElement,this.tmpElement);
            this.inputWrapper.removeChild(this.tmpElement);
        }
    },
    recalcDimensions: function() {
        var o = jcf.lib.getOffset(this.fakeElement);
        this.oTop = o.top;
        this.oLeft = o.left;
        this.oWidth = this.realElement.offsetWidth;
        this.oHeight = this.realElement.offsetHeight;
    },
    refreshState: function(){
        jcf.lib.setStyles(this.realElement, {
            opacity: 0
        });
        this.fileNameInput.innerHTML = this.getFileName() || this.origTitle || '';
        if(this.realElement.disabled) {
            jcf.lib.addClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.addClass(this.labelFor, this.options.labelDisabledClass);
            }
        } else {
            jcf.lib.removeClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.removeClass(this.labelFor, this.options.labelDisabledClass);
            }
        }
        if(this.realElement.value.length) {
            jcf.lib.removeClass(this.fakeElement, this.options.noFileClass);
        } else {
            jcf.lib.addClass(this.fakeElement, this.options.noFileClass);
        }
        this.updateExtensionClass();
    }
});

/*
 * FancyBox - jQuery Plugin
 * Simple and fancy lightbox alternative
 *
 * Examples and documentation at: http://fancybox.net
 * 
 * Copyright (c) 2008 - 2010 Janis Skarnelis
 * That said, it is hardly a one-person project. Many people have submitted bugs, code, and offered their advice freely. Their support is greatly appreciated.
 *
 * Version: 1.3.4 (11/11/2010)
 * Requires: jQuery v1.3+
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
;
(function(B){
    var L,T,Q,M,d,m,J,A,O,z,C=0,H={},j=[],e=0,G={},y=[],f=null,o=new Image(),i=/\.(jpg|gif|png|bmp|jpeg)(.*)?$/i,k=/[^\.]\.(swf)\s*$/i,p,N=1,h=0,t="",b,c,P=false,s=B.extend(B("<div/>")[0],{
        prop:0
    }),S=B.browser.msie&&B.browser.version<7&&!window.XMLHttpRequest,r=function(){
        T.hide();
        o.onerror=o.onload=null;
        if(f){
            f.abort()
        }
        L.empty()
    },x=function(){
        if(false===H.onError(j,C,H)){
            T.hide();
            P=false;
            return
        }
        H.titleShow=false;
        H.width="auto";
        H.height="auto";
        L.html('<p id="fancybox-error">The requested content cannot be loaded.<br />Please try again later.</p>');
        n()
    },w=function(){
        var Z=j[C],W,Y,ab,aa,V,X;
        r();
        H=B.extend({},B.fn.fancybox.defaults,(typeof B(Z).data("fancybox")=="undefined"?H:B(Z).data("fancybox")));
        X=H.onStart(j,C,H);
        if(X===false){
            P=false;
            return
        }else{
            if(typeof X=="object"){
                H=B.extend(H,X)
            }
        }
        ab=H.title||(Z.nodeName?B(Z).attr("title"):Z.title)||"";
        if(Z.nodeName&&!H.orig){
            H.orig=B(Z).children("img:first").length?B(Z).children("img:first"):B(Z)
        }
        if(ab===""&&H.orig&&H.titleFromAlt){
            ab=H.orig.attr("alt")
        }
        W=H.href||(Z.nodeName?B(Z).attr("href"):Z.href)||null;
        if((/^(?:javascript)/i).test(W)||W=="#"){
            W=null
        }
        if(H.type){
            Y=H.type;
            if(!W){
                W=H.content
            }
        }else{
            if(H.content){
                Y="html"
            }else{
                if(W){
                    if(W.match(i)){
                        Y="image"
                    }
                    else{
                        if(W.match(k)){
                            Y="swf"
                        }else{
                            if(B(Z).hasClass("iframe")){
                                Y="iframe"
                            }else{
                                if(W.indexOf("#")===0){
                                    Y="inline"
                                }
                                else{
                                    Y="ajax"
                                }
                            }
                        }
                    }
                }
            }
        }
        if(!Y){
            x();
            return
        }
        if(Y=="inline"){
            Z=W.substr(W.indexOf("#"));
            Y=B(Z).length>0?"inline":"ajax"
        }
        H.type=Y;
        H.href=W;
        H.title=ab;
        if(H.autoDimensions){
            if(H.type=="html"||H.type=="inline"||H.type=="ajax"){
                H.width="auto";
                H.height="auto"
            }else{
                H.autoDimensions=false
            }
        }
        if(H.modal){
            H.overlayShow=true;
            H.hideOnOverlayClick=false;
            H.hideOnContentClick=false;
            H.enableEscapeButton=false;
            H.showCloseButton=false
        }
        H.padding=parseInt(H.padding,10);
        H.margin=parseInt(H.margin,10);
        L.css("padding",(H.padding+H.margin));
        B(".fancybox-inline-tmp").unbind("fancybox-cancel").bind("fancybox-change",function(){
            B(this).replaceWith(m.children())
        });
        switch(Y){
            case"html":
                L.html(H.content);
                n();
                break;
            case"inline":
                if(B(Z).parent().is("#fancybox-content")===true){
                    P=false;
                    return
                }
                B('<div class="fancybox-inline-tmp" />').hide().insertBefore(B(Z)).bind("fancybox-cleanup",function(){
                    B(this).replaceWith(m.children())
                }).bind("fancybox-cancel",function(){
                    B(this).replaceWith(L.children())
                });
                B(Z).appendTo(L);
                n();
                break;
            case"image":
                P=false;
                B.fancybox.showActivity();
                o=new Image();
                o.onerror=function(){
                    x()
                };

                o.onload=function(){
                    P=true;
                    o.onerror=o.onload=null;
                    F()
                };

                o.src=W;
                break;
            case"swf":
                H.scrolling="no";
                aa='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="'+H.width+'" height="'+H.height+'"><param name="movie" value="'+W+'"></param>';
                V="";
                B.each(H.swf,function(ac,ad){
                    aa+='<param name="'+ac+'" value="'+ad+'"></param>';
                    V+=" "+ac+'="'+ad+'"'
                });
                aa+='<embed src="'+W+'" type="application/x-shockwave-flash" width="'+H.width+'" height="'+H.height+'"'+V+"></embed></object>";
                L.html(aa);
                n();
                break;
            case"ajax":
                P=false;
                B.fancybox.showActivity();
                H.ajax.win=H.ajax.success;
                f=B.ajax(B.extend({},H.ajax,{
                    url:W,
                    data:H.ajax.data||{},
                    dataType:"text",
                    error:function(ac,ae,ad){
                        if(ac.status>0){
                            x()
                        }
                    },
                    success:function(ad,af,ac){
                        var ae=typeof ac=="object"?ac:f;
                        if(ae.status==200||ae.status===0){
                            if(typeof H.ajax.win=="function"){
                                X=H.ajax.win(W,ad,af,ac);
                                if(X===false){
                                    T.hide();
                                    return
                                }else{
                                    if(typeof X=="string"||typeof X=="object"){
                                        ad=X
                                    }
                                }
                            }
                            L.html(ad);
                            n()
                        }
                    }
                }));
                break;
            case"iframe":
                E();
                break
        }
    },n=function(){
        var V=H.width,W=H.height;
        if(V.toString().indexOf("%")>-1){
            V=parseInt((B(window).width()-(H.margin*2))*parseFloat(V)/100,10)+"px"
        }else{
            V=V=="auto"?"auto":V+"px"
        }
        if(W.toString().indexOf("%")>-1){
            W=parseInt((B(window).height()-(H.margin*2))*parseFloat(W)/100,10)+"px"
        }else{
            W=W=="auto"?"auto":W+"px"
        }
        L.wrapInner('<div style="width:'+V+";height:"+W+";overflow: "+(H.scrolling=="auto"?"auto":(H.scrolling=="yes"?"scroll":"hidden"))+';position:relative;"></div>');
        H.width=L.width();
        H.height=L.height();
        E()
    },F=function(){
        H.width=o.width;
        H.height=o.height;
        B("<img />").attr({
            id:"fancybox-img",
            src:o.src,
            alt:H.title
        }).appendTo(L);
        E()
    },E=function(){
        var W,V;
        T.hide();
        if(M.is(":visible")&&false===G.onCleanup(y,e,G)){
            B.event.trigger("fancybox-cancel");
            P=false;
            return
        }
        P=true;
        B(m.add(Q)).unbind();
        B(window).unbind("resize.fb scroll.fb");
        B(document).unbind("keydown.fb");
        if(M.is(":visible")&&G.titlePosition!=="outside"){
            M.css("height",M.height())
        }
        y=j;
        e=C;
        G=H;
        if(G.overlayShow){
            Q.css({
                "background-color":G.overlayColor,
                opacity:G.overlayOpacity,
                cursor:G.hideOnOverlayClick?"pointer":"auto",
                height:B(document).height()
            });
            if(!Q.is(":visible")){
                if(S){
                    B("select:not(#fancybox-tmp select)").filter(function(){
                        return this.style.visibility!=="hidden"
                    }).css({
                        visibility:"hidden"
                    }).one("fancybox-cleanup",function(){
                        this.style.visibility="inherit"
                    })
                }
                Q.show()
            }
        }else{
            Q.hide()
        }
        c=R();
        l();
        if(M.is(":visible")){
            B(J.add(O).add(z)).hide();
            W=M.position(),b={
                top:W.top,
                left:W.left,
                width:M.width(),
                height:M.height()
            };

            V=(b.width==c.width&&b.height==c.height);
            m.fadeTo(G.changeFade,0.3,function(){
                var X=function(){
                    m.html(L.contents()).fadeTo(G.changeFade,1,v)
                };

                B.event.trigger("fancybox-change");
                m.empty().removeAttr("filter").css({
                    "border-width":G.padding,
                    width:c.width-G.padding*2,
                    height:H.autoDimensions?"auto":c.height-h-G.padding*2
                });
                if(V){
                    X()
                }else{
                    s.prop=0;
                    B(s).animate({
                        prop:1
                    },{
                        duration:G.changeSpeed,
                        easing:G.easingChange,
                        step:U,
                        complete:X
                    })
                }
            });
            return
        }
        M.removeAttr("style");
        m.css("border-width",G.padding);
        if(G.transitionIn=="elastic"){
            b=I();
            m.html(L.contents());
            M.show();
            if(G.opacity){
                c.opacity=0
            }
            s.prop=0;
            B(s).animate({
                prop:1
            },{
                duration:G.speedIn,
                easing:G.easingIn,
                step:U,
                complete:v
            });
            return
        }
        if(G.titlePosition=="inside"&&h>0){
            A.show()
        }
        m.css({
            width:c.width-G.padding*2,
            height:H.autoDimensions?"auto":c.height-h-G.padding*2
        }).html(L.contents());
        M.css(c).fadeIn(G.transitionIn=="none"?0:G.speedIn,v)
    },D=function(V){
        if(V&&V.length){
            if(G.titlePosition=="float"){
                return'<table id="fancybox-title-float-wrap" cellpadding="0" cellspacing="0"><tr><td id="fancybox-title-float-left"></td><td id="fancybox-title-float-main">'+V+'</td><td id="fancybox-title-float-right"></td></tr></table>'
            }
            return'<div id="fancybox-title-'+G.titlePosition+'">'+V+"</div>"
        }
        return false
    },l=function(){
        t=G.title||"";
        h=0;
        A.empty().removeAttr("style").removeClass();
        if(G.titleShow===false){
            A.hide();
            return
        }
        t=B.isFunction(G.titleFormat)?G.titleFormat(t,y,e,G):D(t);
        if(!t||t===""){
            A.hide();
            return
        }
        A.addClass("fancybox-title-"+G.titlePosition).html(t).appendTo("body").show();
        switch(G.titlePosition){
            case"inside":
                A.css({
                    width:c.width-(G.padding*2),
                    marginLeft:G.padding,
                    marginRight:G.padding
                });
                h=A.outerHeight(true);
                A.appendTo(d);
                c.height+=h;
                break;
            case"over":
                A.css({
                    marginLeft:G.padding,
                    width:c.width-(G.padding*2),
                    bottom:G.padding
                }).appendTo(d);
                break;
            case"float":
                A.css("left",parseInt((A.width()-c.width-40)/2,10)*-1).appendTo(M);
                break;
            default:
                A.css({
                    width:c.width-(G.padding*2),
                    paddingLeft:G.padding,
                    paddingRight:G.padding
                }).appendTo(M);
                break
        }
        A.hide()
    },g=function(){
        if(G.enableEscapeButton||G.enableKeyboardNav){
            B(document).bind("keydown.fb",function(V){
                if(V.keyCode==27&&G.enableEscapeButton){
                    V.preventDefault();
                    B.fancybox.close()
                }else{
                    if((V.keyCode==37||V.keyCode==39)&&G.enableKeyboardNav&&V.target.tagName!=="INPUT"&&V.target.tagName!=="TEXTAREA"&&V.target.tagName!=="SELECT"){
                        V.preventDefault();
                        B.fancybox[V.keyCode==37?"prev":"next"]()
                    }
                }
            })
        }
        if(!G.showNavArrows){
            O.hide();
            z.hide();
            return
        }
        if((G.cyclic&&y.length>1)||e!==0){
            O.show()
        }
        if((G.cyclic&&y.length>1)||e!=(y.length-1)){
            z.show()
        }
    },v=function(){
        if(!B.support.opacity){
            m.get(0).style.removeAttribute("filter");
            M.get(0).style.removeAttribute("filter")
        }
        if(H.autoDimensions){
            m.css("height","auto")
        }
        M.css("height","auto");
        if(t&&t.length){
            A.show()
        }
        if(G.showCloseButton){
            J.show()
        }
        g();
        if(G.hideOnContentClick){
            m.bind("click",B.fancybox.close)
        }
        if(G.hideOnOverlayClick){
            Q.bind("click",B.fancybox.close)
        }
        B(window).bind("resize.fb",B.fancybox.resize);
        if(G.centerOnScroll){
            B(window).bind("scroll.fb",B.fancybox.center)
        }
        if(G.type=="iframe"){
            B('<iframe id="fancybox-frame" name="fancybox-frame'+new Date().getTime()+'" frameborder="0" hspace="0" '+(B.browser.msie?'allowtransparency="true""':"")+' scrolling="'+H.scrolling+'" src="'+G.href+'"></iframe>').appendTo(m)
        }
        M.show();
        P=false;
        B.fancybox.center();
        G.onComplete(y,e,G);
        K()
    },K=function(){
        var V,W;
        if((y.length-1)>e){
            V=y[e+1].href;
            if(typeof V!=="undefined"&&V.match(i)){
                W=new Image();
                W.src=V
            }
        }
        if(e>0){
            V=y[e-1].href;
            if(typeof V!=="undefined"&&V.match(i)){
                W=new Image();
                W.src=V
            }
        }
    },U=function(W){
        var V={
            width:parseInt(b.width+(c.width-b.width)*W,10),
            height:parseInt(b.height+(c.height-b.height)*W,10),
            top:parseInt(b.top+(c.top-b.top)*W,10),
            left:parseInt(b.left+(c.left-b.left)*W,10)
        };

        if(typeof c.opacity!=="undefined"){
            V.opacity=W<0.5?0.5:W
        }
        M.css(V);
        m.css({
            width:V.width-G.padding*2,
            height:V.height-(h*W)-G.padding*2
        })
    },u=function(){
        return[B(window).width()-(G.margin*2),B(window).height()-(G.margin*2),B(document).scrollLeft()+G.margin,B(document).scrollTop()+G.margin]
    },R=function(){
        var V=u(),Z={},W=G.autoScale,X=G.padding*2,Y;
        if(G.width.toString().indexOf("%")>-1){
            Z.width=parseInt((V[0]*parseFloat(G.width))/100,10)
        }else{
            Z.width=G.width+X
        }
        if(G.height.toString().indexOf("%")>-1){
            Z.height=parseInt((V[1]*parseFloat(G.height))/100,10)
        }else{
            Z.height=G.height+X
        }
        if(W&&(Z.width>V[0]||Z.height>V[1])){
            if(H.type=="image"||H.type=="swf"){
                Y=(G.width)/(G.height);
                if((Z.width)>V[0]){
                    Z.width=V[0];
                    Z.height=parseInt(((Z.width-X)/Y)+X,10)
                }
                if((Z.height)>V[1]){
                    Z.height=V[1];
                    Z.width=parseInt(((Z.height-X)*Y)+X,10)
                }
            }else{
                Z.width=Math.min(Z.width,V[0]);
                Z.height=Math.min(Z.height,V[1])
            }
        }
        Z.top=parseInt(Math.max(V[3]-20,V[3]+((V[1]-Z.height-40)*0.5)),10);
        Z.left=parseInt(Math.max(V[2]-20,V[2]+((V[0]-Z.width-40)*0.5)),10);
        return Z
    },q=function(V){
        var W=V.offset();
        W.top+=parseInt(V.css("paddingTop"),10)||0;
        W.left+=parseInt(V.css("paddingLeft"),10)||0;
        W.top+=parseInt(V.css("border-top-width"),10)||0;
        W.left+=parseInt(V.css("border-left-width"),10)||0;
        W.width=V.width();
        W.height=V.height();
        return W
    },I=function(){
        var Y=H.orig?B(H.orig):false,X={},W,V;
        if(Y&&Y.length){
            W=q(Y);
            X={
                width:W.width+(G.padding*2),
                height:W.height+(G.padding*2),
                top:W.top-G.padding-20,
                left:W.left-G.padding-20
            }
        }else{
            V=u();
            X={
                width:G.padding*2,
                height:G.padding*2,
                top:parseInt(V[3]+V[1]*0.5,10),
                left:parseInt(V[2]+V[0]*0.5,10)
            }
        }
        return X
    },a=function(){
        if(!T.is(":visible")){
            clearInterval(p);
            return
        }
        B("div",T).css("top",(N*-40)+"px");
        N=(N+1)%12
    };

    B.fn.fancybox=function(V){
        if(!B(this).length){
            return this
        }
        B(this).data("fancybox",B.extend({},V,(B.metadata?B(this).metadata():{}))).unbind("click.fb").bind("click.fb",function(X){
            X.preventDefault();
            if(P){
                return
            }
            P=true;
            B(this).blur();
            j=[];
            C=0;
            var W=B(this).attr("rel")||"";
            if(!W||W==""||W==="nofollow"){
                j.push(this)
            }else{
                j=B('a[rel="'+W+'"], area[rel="'+W+'"]');
                C=j.index(this)
            }
            w();
            return
        });
        return this
    };

    B.fancybox=function(Y){
        var X;
        if(P){
            return
        }
        P=true;
        X=typeof arguments[1]!=="undefined"?arguments[1]:{};

        j=[];
        C=parseInt(X.index,10)||0;
        if(B.isArray(Y)){
            for(var W=0,V=Y.length;W<V;W++){
                if(typeof Y[W]=="object"){
                    B(Y[W]).data("fancybox",B.extend({},X,Y[W]))
                }else{
                    Y[W]=B({}).data("fancybox",B.extend({
                        content:Y[W]
                    },X))
                }
            }
            j=jQuery.merge(j,Y)
        }else{
            if(typeof Y=="object"){
                B(Y).data("fancybox",B.extend({},X,Y))
            }else{
                Y=B({}).data("fancybox",B.extend({
                    content:Y
                },X))
            }
            j.push(Y)
        }
        if(C>j.length||C<0){
            C=0
        }
        w()
    };

    B.fancybox.showActivity=function(){
        clearInterval(p);
        T.show();
        p=setInterval(a,66)
    };

    B.fancybox.hideActivity=function(){
        T.hide()
    };

    B.fancybox.next=function(){
        return B.fancybox.pos(e+1)
    };

    B.fancybox.prev=function(){
        return B.fancybox.pos(e-1)
    };

    B.fancybox.pos=function(V){
        if(P){
            return
        }
        V=parseInt(V);
        j=y;
        if(V>-1&&V<y.length){
            C=V;
            w()
        }else{
            if(G.cyclic&&y.length>1){
                C=V>=y.length?0:y.length-1;
                w()
            }
        }
        return
    };

    B.fancybox.cancel=function(){
        if(P){
            return
        }
        P=true;
        B.event.trigger("fancybox-cancel");
        r();
        H.onCancel(j,C,H);
        P=false
    };

    B.fancybox.close=function(){
        if(P||M.is(":hidden")){
            return
        }
        P=true;
        if(G&&false===G.onCleanup(y,e,G)){
            P=false;
            return
        }
        r();
        B(J.add(O).add(z)).hide();
        B(m.add(Q)).unbind();
        B(window).unbind("resize.fb scroll.fb");
        B(document).unbind("keydown.fb");
        if(G.type==="iframe"){
            m.find("iframe").attr("src",S&&/^https/i.test(window.location.href||"")?"javascript:void(false)":"about:blank")
        }
        if(G.titlePosition!=="inside"){
            A.empty()
        }
        M.stop();
        function V(){
            Q.fadeOut("fast");
            A.empty().hide();
            M.hide();
            B.event.trigger("fancybox-cleanup");
            m.empty();
            G.onClosed(y,e,G);
            y=H=[];
            e=C=0;
            G=H={};

            P=false
        }
        if(G.transitionOut=="elastic"){
            b=I();
            var W=M.position();
            c={
                top:W.top,
                left:W.left,
                width:M.width(),
                height:M.height()
            };

            if(G.opacity){
                c.opacity=1
            }
            A.empty().hide();
            s.prop=1;
            B(s).animate({
                prop:0
            },{
                duration:G.speedOut,
                easing:G.easingOut,
                step:U,
                complete:V
            })
        }else{
            M.fadeOut(G.transitionOut=="none"?0:G.speedOut,V)
        }
    };

    B.fancybox.resize=function(){
        if(Q.is(":visible")){
            Q.css("height",B(document).height())
        }
        B.fancybox.center(true)
    };

    B.fancybox.center=function(){
        var V,W;
        if(P){
            return
        }
        W=arguments[0]===true?1:0;
        V=u();
        if(!W&&(M.width()>V[0]||M.height()>V[1])){
            return
        }
        M.stop().animate({
            top:parseInt(Math.max(V[3]-20,V[3]+((V[1]-m.height()-40)*0.5)-G.padding)),
            left:parseInt(Math.max(V[2]-20,V[2]+((V[0]-m.width()-40)*0.5)-G.padding))
        },typeof arguments[0]=="number"?arguments[0]:200)
    };

    B.fancybox.init=function(){
        if(B("#fancybox-wrap").length){
            return
        }
        B("body").append(L=B('<div id="fancybox-tmp"></div>'),T=B('<div id="fancybox-loading"><div></div></div>'),Q=B('<div id="fancybox-overlay"></div>'),M=B('<div id="fancybox-wrap"></div>'));
        d=B('<div id="fancybox-outer"></div>').append('<div class="fancybox-bg" id="fancybox-bg-n"></div><div class="fancybox-bg" id="fancybox-bg-ne"></div><div class="fancybox-bg" id="fancybox-bg-e"></div><div class="fancybox-bg" id="fancybox-bg-se"></div><div class="fancybox-bg" id="fancybox-bg-s"></div><div class="fancybox-bg" id="fancybox-bg-sw"></div><div class="fancybox-bg" id="fancybox-bg-w"></div><div class="fancybox-bg" id="fancybox-bg-nw"></div>').appendTo(M);
        d.append(m=B('<div id="fancybox-content"></div>'),J=B('<a id="fancybox-close"></a>'),A=B('<div id="fancybox-title"></div>'),O=B('<a href="javascript:;" id="fancybox-left"><span class="fancy-ico" id="fancybox-left-ico"></span></a>'),z=B('<a href="javascript:;" id="fancybox-right"><span class="fancy-ico" id="fancybox-right-ico"></span></a>'));
        J.click(B.fancybox.close);
        T.click(B.fancybox.cancel);
        O.click(function(V){
            V.preventDefault();
            B.fancybox.prev()
        });
        z.click(function(V){
            V.preventDefault();
            B.fancybox.next()
        });
        if(B.fn.mousewheel){
            M.bind("mousewheel.fb",function(V,W){
                if(P){
                    V.preventDefault()
                }else{
                    if(B(V.target).get(0).clientHeight==0||B(V.target).get(0).scrollHeight===B(V.target).get(0).clientHeight){
                        V.preventDefault();
                        B.fancybox[W>0?"prev":"next"]()
                    }
                }
            })
        }
        if(!B.support.opacity){
            M.addClass("fancybox-ie")
        }
        if(S){
            T.addClass("fancybox-ie6");
            M.addClass("fancybox-ie6");
            B('<iframe id="fancybox-hide-sel-frame" src="'+(/^https/i.test(window.location.href||"")?"javascript:void(false)":"about:blank")+'" scrolling="no" border="0" frameborder="0" tabindex="-1"></iframe>').prependTo(d)
        }
    };

    B.fn.fancybox.defaults={
        padding:10,
        margin:40,
        opacity:false,
        modal:false,
        cyclic:false,
        scrolling:"auto",
        width:560,
        height:340,
        autoScale:true,
        autoDimensions:true,
        centerOnScroll:false,
        ajax:{},
        swf:{
            wmode:"transparent"
        },
        hideOnOverlayClick:true,
        hideOnContentClick:false,
        overlayShow:true,
        overlayOpacity:0.7,
        overlayColor:"#777",
        titleShow:true,
        titlePosition:"float",
        titleFormat:null,
        titleFromAlt:false,
        transitionIn:"fade",
        transitionOut:"fade",
        speedIn:300,
        speedOut:300,
        changeSpeed:300,
        changeFade:"fast",
        easingIn:"swing",
        easingOut:"swing",
        showCloseButton:true,
        showNavArrows:true,
        enableEscapeButton:true,
        enableKeyboardNav:true,
        onStart:function(){},
        onCancel:function(){},
        onComplete:function(){},
        onCleanup:function(){},
        onClosed:function(){},
        onError:function(){}
    };

    B(document).ready(function(){
        B.fancybox.init()
    })
})(jQuery);

/*
 * jQuery Easing v1.3 - http://gsgd.co.uk/sandbox/jquery/easing/
 *
 * Uses the built in easing capabilities added In jQuery 1.1
 * to offer multiple easing options
 *
 * TERMS OF USE - jQuery Easing
 * 
 * Open source under the BSD License. 
 * 
 * Copyright ? 2008 George McGinley Smith
 * All rights reserved.
 * 
 */
;
jQuery.easing.jswing=jQuery.easing.swing;
jQuery.extend(jQuery.easing,{
    def:"easeOutQuad",
    swing:function(e,f,a,h,g){
        return jQuery.easing[jQuery.easing.def](e,f,a,h,g)
    },
    easeInQuad:function(e,f,a,h,g){
        return h*(f/=g)*f+a
    },
    easeOutQuad:function(e,f,a,h,g){
        return -h*(f/=g)*(f-2)+a
    },
    easeInOutQuad:function(e,f,a,h,g){
        if((f/=g/2)<1){
            return h/2*f*f+a
        }
        return -h/2*((--f)*(f-2)-1)+a
    },
    easeInCubic:function(e,f,a,h,g){
        return h*(f/=g)*f*f+a
    },
    easeOutCubic:function(e,f,a,h,g){
        return h*((f=f/g-1)*f*f+1)+a
    },
    easeInOutCubic:function(e,f,a,h,g){
        if((f/=g/2)<1){
            return h/2*f*f*f+a
        }
        return h/2*((f-=2)*f*f+2)+a
    },
    easeInQuart:function(e,f,a,h,g){
        return h*(f/=g)*f*f*f+a
    },
    easeOutQuart:function(e,f,a,h,g){
        return -h*((f=f/g-1)*f*f*f-1)+a
    },
    easeInOutQuart:function(e,f,a,h,g){
        if((f/=g/2)<1){
            return h/2*f*f*f*f+a
        }
        return -h/2*((f-=2)*f*f*f-2)+a
    },
    easeInQuint:function(e,f,a,h,g){
        return h*(f/=g)*f*f*f*f+a
    },
    easeOutQuint:function(e,f,a,h,g){
        return h*((f=f/g-1)*f*f*f*f+1)+a
    },
    easeInOutQuint:function(e,f,a,h,g){
        if((f/=g/2)<1){
            return h/2*f*f*f*f*f+a
        }
        return h/2*((f-=2)*f*f*f*f+2)+a
    },
    easeInSine:function(e,f,a,h,g){
        return -h*Math.cos(f/g*(Math.PI/2))+h+a
    },
    easeOutSine:function(e,f,a,h,g){
        return h*Math.sin(f/g*(Math.PI/2))+a
    },
    easeInOutSine:function(e,f,a,h,g){
        return -h/2*(Math.cos(Math.PI*f/g)-1)+a
    },
    easeInExpo:function(e,f,a,h,g){
        return(f==0)?a:h*Math.pow(2,10*(f/g-1))+a
    },
    easeOutExpo:function(e,f,a,h,g){
        return(f==g)?a+h:h*(-Math.pow(2,-10*f/g)+1)+a
    },
    easeInOutExpo:function(e,f,a,h,g){
        if(f==0){
            return a
        }
        if(f==g){
            return a+h
        }
        if((f/=g/2)<1){
            return h/2*Math.pow(2,10*(f-1))+a
        }
        return h/2*(-Math.pow(2,-10*--f)+2)+a
    },
    easeInCirc:function(e,f,a,h,g){
        return -h*(Math.sqrt(1-(f/=g)*f)-1)+a
    },
    easeOutCirc:function(e,f,a,h,g){
        return h*Math.sqrt(1-(f=f/g-1)*f)+a
    },
    easeInOutCirc:function(e,f,a,h,g){
        if((f/=g/2)<1){
            return -h/2*(Math.sqrt(1-f*f)-1)+a
        }
        return h/2*(Math.sqrt(1-(f-=2)*f)+1)+a
    },
    easeInElastic:function(f,h,e,l,k){
        var i=1.70158;
        var j=0;
        var g=l;
        if(h==0){
            return e
        }
        if((h/=k)==1){
            return e+l
        }
        if(!j){
            j=k*0.3
        }
        if(g<Math.abs(l)){
            g=l;
            var i=j/4
        }else{
            var i=j/(2*Math.PI)*Math.asin(l/g)
        }
        return -(g*Math.pow(2,10*(h-=1))*Math.sin((h*k-i)*(2*Math.PI)/j))+e
    },
    easeOutElastic:function(f,h,e,l,k){
        var i=1.70158;
        var j=0;
        var g=l;
        if(h==0){
            return e
        }
        if((h/=k)==1){
            return e+l
        }
        if(!j){
            j=k*0.3
        }
        if(g<Math.abs(l)){
            g=l;
            var i=j/4
        }else{
            var i=j/(2*Math.PI)*Math.asin(l/g)
        }
        return g*Math.pow(2,-10*h)*Math.sin((h*k-i)*(2*Math.PI)/j)+l+e
    },
    easeInOutElastic:function(f,h,e,l,k){
        var i=1.70158;
        var j=0;
        var g=l;
        if(h==0){
            return e
        }
        if((h/=k/2)==2){
            return e+l
        }
        if(!j){
            j=k*(0.3*1.5)
        }
        if(g<Math.abs(l)){
            g=l;
            var i=j/4
        }else{
            var i=j/(2*Math.PI)*Math.asin(l/g)
        }
        if(h<1){
            return -0.5*(g*Math.pow(2,10*(h-=1))*Math.sin((h*k-i)*(2*Math.PI)/j))+e
        }
        return g*Math.pow(2,-10*(h-=1))*Math.sin((h*k-i)*(2*Math.PI)/j)*0.5+l+e
    },
    easeInBack:function(e,f,a,i,h,g){
        if(g==undefined){
            g=1.70158
        }
        return i*(f/=h)*f*((g+1)*f-g)+a
    },
    easeOutBack:function(e,f,a,i,h,g){
        if(g==undefined){
            g=1.70158
        }
        return i*((f=f/h-1)*f*((g+1)*f+g)+1)+a
    },
    easeInOutBack:function(e,f,a,i,h,g){
        if(g==undefined){
            g=1.70158
        }
        if((f/=h/2)<1){
            return i/2*(f*f*(((g*=(1.525))+1)*f-g))+a
        }
        return i/2*((f-=2)*f*(((g*=(1.525))+1)*f+g)+2)+a
    },
    easeInBounce:function(e,f,a,h,g){
        return h-jQuery.easing.easeOutBounce(e,g-f,0,h,g)+a
    },
    easeOutBounce:function(e,f,a,h,g){
        if((f/=g)<(1/2.75)){
            return h*(7.5625*f*f)+a
        }else{
            if(f<(2/2.75)){
                return h*(7.5625*(f-=(1.5/2.75))*f+0.75)+a
            }else{
                if(f<(2.5/2.75)){
                    return h*(7.5625*(f-=(2.25/2.75))*f+0.9375)+a
                }else{
                    return h*(7.5625*(f-=(2.625/2.75))*f+0.984375)+a
                }
            }
        }
    },
    easeInOutBounce:function(e,f,a,h,g){
        if(f<g/2){
            return jQuery.easing.easeInBounce(e,f*2,0,h,g)*0.5+a
        }
        return jQuery.easing.easeOutBounce(e,f*2-g,0,h,g)*0.5+h*0.5+a
    }
});

/*! Copyright (c) 2011 Brandon Aaron (http://brandonaaron.net)
 * Licensed under the MIT License (LICENSE.txt).
 *
 * Thanks to: http://adomas.org/javascript-mouse-wheel/ for some pointers.
 * Thanks to: Mathias Bank(http://www.mathias-bank.de) for a scope bug fix.
 * Thanks to: Seamus Leahy for adding deltaX and deltaY
 *
 * Version: 3.0.6
 * 
 * Requires: 1.2.2+
 */
;
(function(a){
    function d(b){
        var c=b||window.event,d=[].slice.call(arguments,1),e=0,f=!0,g=0,h=0;
        return b=a.event.fix(c),b.type="mousewheel",c.wheelDelta&&(e=c.wheelDelta/120),c.detail&&(e=-c.detail/3),h=e,c.axis!==undefined&&c.axis===c.HORIZONTAL_AXIS&&(h=0,g=-1*e),c.wheelDeltaY!==undefined&&(h=c.wheelDeltaY/120),c.wheelDeltaX!==undefined&&(g=-1*c.wheelDeltaX/120),d.unshift(b,e,g,h),(a.event.dispatch||a.event.handle).apply(this,d)
    }
    var b=["DOMMouseScroll","mousewheel"];
    if(a.event.fixHooks)for(var c=b.length;c;)a.event.fixHooks[b[--c]]=a.event.mouseHooks;
    a.event.special.mousewheel={
        setup:function(){
            if(this.addEventListener)for(var a=b.length;a;)this.addEventListener(b[--a],d,!1);else this.onmousewheel=d
        },
        teardown:function(){
            if(this.removeEventListener)for(var a=b.length;a;)this.removeEventListener(b[--a],d,!1);else this.onmousewheel=null
        }
    },a.fn.extend({
        mousewheel:function(a){
            return a?this.bind("mousewheel",a):this.trigger("mousewheel")
        },
        unmousewheel:function(a){
            return this.unbind("mousewheel",a)
        }
    })
})(jQuery) 

/*! HTML5 Shiv vpre3.6 | @afarkas @jdalton @jon_neal @rem | MIT/GPL2 Licensed */
;
(function(o,s){
    var g=o.html5||{};

    var j=/^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i;
    var d=/^<|^(?:a|b|button|code|div|fieldset|form|h1|h2|h3|h4|h5|h6|i|iframe|img|input|label|li|link|ol|option|p|param|q|script|select|span|strong|style|table|tbody|td|textarea|tfoot|th|thead|tr|ul)$/i;
    var x;
    var k="_html5shiv";
    var c=0;
    var u={};

    var h;
    (function(){
        var A=s.createElement("a");
        A.innerHTML="<xyz></xyz>";
        x=("hidden" in A);
        h=A.childNodes.length==1||(function(){
            try{
                (s.createElement)("a")
            }catch(B){
                return true
            }
            var C=s.createDocumentFragment();
            return(typeof C.cloneNode=="undefined"||typeof C.createDocumentFragment=="undefined"||typeof C.createElement=="undefined")
        }())
    }());
    function i(A,C){
        var D=A.createElement("p"),B=A.getElementsByTagName("head")[0]||A.documentElement;
        D.innerHTML="x<style>"+C+"</style>";
        return B.insertBefore(D.lastChild,B.firstChild)
    }
    function q(){
        var A=n.elements;
        return typeof A=="string"?A.split(" "):A
    }
    function w(A){
        var B=u[A[k]];
        if(!B){
            B={};

            c++;
            A[k]=c;
            u[c]=B
        }
        return B
    }
    function t(D,A,C){
        if(!A){
            A=s
        }
        if(h){
            return A.createElement(D)
        }
        C=C||w(A);
        var B;
        if(C.cache[D]){
            B=C.cache[D].cloneNode()
        }else{
            if(d.test(D)){
                B=(C.cache[D]=C.createElem(D)).cloneNode()
            }else{
                B=C.createElem(D)
            }
        }
        return B.canHaveChildren&&!j.test(D)?C.frag.appendChild(B):B
    }
    function y(C,E){
        if(!C){
            C=s
        }
        if(h){
            return C.createDocumentFragment()
        }
        E=E||w(C);
        var F=E.frag.cloneNode(),D=0,B=q(),A=B.length;
        for(;D<A;D++){
            F.createElement(B[D])
        }
        return F
    }
    function z(A,B){
        if(!B.cache){
            B.cache={};

            B.createElem=A.createElement;
            B.createFrag=A.createDocumentFragment;
            B.frag=B.createFrag()
        }
        A.createElement=function(C){
            if(!n.shivMethods){
                return B.createElem(C)
            }
            return t(C)
        };

        A.createDocumentFragment=Function("h,f","return function(){var n=f.cloneNode(),c=n.createElement;h.shivMethods&&("+q().join().replace(/\w+/g,function(C){
            B.createElem(C);
            B.frag.createElement(C);
            return'c("'+C+'")'
        })+");return n}")(n,B.frag)
    }
    function e(A){
        if(!A){
            A=s
        }
        var B=w(A);
        if(n.shivCSS&&!x&&!B.hasCSS){
            B.hasCSS=!!i(A,"article,aside,figcaption,figure,footer,header,hgroup,nav,section{display:block}mark{background:#FF0;color:#000}")
        }
        if(!h){
            z(A,B)
        }
        return A
    }
    var n={
        elements:g.elements||"abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video",
        shivCSS:!(g.shivCSS===false),
        supportsUnknownElements:h,
        shivMethods:!(g.shivMethods===false),
        type:"default",
        shivDocument:e,
        createElement:t,
        createDocumentFragment:y
    };

    o.html5=n;
    e(s);
    var b=/^$|\b(?:all|print)\b/;
    var l="html5shiv";
    var r=!h&&(function(){
        var A=s.documentElement;
        return !(typeof s.namespaces=="undefined"||typeof s.parentWindow=="undefined"||typeof A.applyElement=="undefined"||typeof A.removeNode=="undefined"||typeof o.attachEvent=="undefined")
    }());
    function f(E){
        var F,C=E.getElementsByTagName("*"),D=C.length,B=RegExp("^(?:"+q().join("|")+")$","i"),A=[];
        while(D--){
            F=C[D];
            if(B.test(F.nodeName)){
                A.push(F.applyElement(v(F)))
            }
        }
        return A
    }
    function v(C){
        var D,A=C.attributes,B=A.length,E=C.ownerDocument.createElement(l+":"+C.nodeName);
        while(B--){
            D=A[B];
            D.specified&&E.setAttribute(D.nodeName,D.nodeValue)
        }
        E.style.cssText=C.style.cssText;
        return E
    }
    function a(D){
        var F,E=D.split("{"),B=E.length,A=RegExp("(^|[\\s,>+~])("+q().join("|")+")(?=[[\\s,>+~#.:]|$)","gi"),C="$1"+l+"\\:$2";
        while(B--){
            F=E[B]=E[B].split("}");
            F[F.length-1]=F[F.length-1].replace(A,C);
            E[B]=F.join("}")
        }
        return E.join("{")
    }
    function p(B){
        var A=B.length;
        while(A--){
            B[A].removeNode()
        }
    }
    function m(A){
        var E,C,B=A.namespaces,D=A.parentWindow;
        if(!r||A.printShived){
            return A
        }
        if(typeof B[l]=="undefined"){
            B.add(l)
        }
        D.attachEvent("onbeforeprint",function(){
            var F,J,H,L=A.styleSheets,I=[],G=L.length,K=Array(G);
            while(G--){
                K[G]=L[G]
            }while((H=K.pop())){
                if(!H.disabled&&b.test(H.media)){
                    try{
                        F=H.imports;
                        J=F.length
                    }catch(M){
                        J=0
                    }
                    for(G=0;G<J;G++){
                        K.push(F[G])
                    }
                    try{
                        I.push(H.cssText)
                    }catch(M){}
                }
            }
            I=a(I.reverse().join(""));
            C=f(A);
            E=i(A,I)
        });
        D.attachEvent("onafterprint",function(){
            p(C);
            E.removeNode(true)
        });
        A.printShived=true;
        return A
    }
    n.type+=" print";
    n.shivPrint=m;
    m(s)
}(this,document));

/*
 * jQuery Easing v1.3 - http://gsgd.co.uk/sandbox/jquery/easing/
 *
 * Uses the built in easing capabilities added In jQuery 1.1
 * to offer multiple easing options
 *
 * TERMS OF USE - jQuery Easing
 * 
 * Open source under the BSD License. 
 * 
 * Copyright © 2008 George McGinley Smith
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
*/

// t: current time, b: begInnIng value, c: change In value, d: duration
jQuery.easing['jswing'] = jQuery.easing['swing'];

jQuery.extend( jQuery.easing,
{
    def: 'easeOutQuad',
    swing: function (x, t, b, c, d) {
        //alert(jQuery.easing.default);
        return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
    },
    easeInQuad: function (x, t, b, c, d) {
        return c*(t/=d)*t + b;
    },
    easeOutQuad: function (x, t, b, c, d) {
        return -c *(t/=d)*(t-2) + b;
    },
    easeInOutQuad: function (x, t, b, c, d) {
        if ((t/=d/2) < 1) return c/2*t*t + b;
        return -c/2 * ((--t)*(t-2) - 1) + b;
    },
    easeInCubic: function (x, t, b, c, d) {
        return c*(t/=d)*t*t + b;
    },
    easeOutCubic: function (x, t, b, c, d) {
        return c*((t=t/d-1)*t*t + 1) + b;
    },
    easeInOutCubic: function (x, t, b, c, d) {
        if ((t/=d/2) < 1) return c/2*t*t*t + b;
        return c/2*((t-=2)*t*t + 2) + b;
    },
    easeInQuart: function (x, t, b, c, d) {
        return c*(t/=d)*t*t*t + b;
    },
    easeOutQuart: function (x, t, b, c, d) {
        return -c * ((t=t/d-1)*t*t*t - 1) + b;
    },
    easeInOutQuart: function (x, t, b, c, d) {
        if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
        return -c/2 * ((t-=2)*t*t*t - 2) + b;
    },
    easeInQuint: function (x, t, b, c, d) {
        return c*(t/=d)*t*t*t*t + b;
    },
    easeOutQuint: function (x, t, b, c, d) {
        return c*((t=t/d-1)*t*t*t*t + 1) + b;
    },
    easeInOutQuint: function (x, t, b, c, d) {
        if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
        return c/2*((t-=2)*t*t*t*t + 2) + b;
    },
    easeInSine: function (x, t, b, c, d) {
        return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
    },
    easeOutSine: function (x, t, b, c, d) {
        return c * Math.sin(t/d * (Math.PI/2)) + b;
    },
    easeInOutSine: function (x, t, b, c, d) {
        return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
    },
    easeInExpo: function (x, t, b, c, d) {
        return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
    },
    easeOutExpo: function (x, t, b, c, d) {
        return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
    },
    easeInOutExpo: function (x, t, b, c, d) {
        if (t==0) return b;
        if (t==d) return b+c;
        if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
        return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
    },
    easeInCirc: function (x, t, b, c, d) {
        return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
    },
    easeOutCirc: function (x, t, b, c, d) {
        return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
    },
    easeInOutCirc: function (x, t, b, c, d) {
        if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
        return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
    },
    easeInElastic: function (x, t, b, c, d) {
        var s=1.70158;
        var p=0;
        var a=c;
        if (t==0) return b;
        if ((t/=d)==1) return b+c;
        if (!p) p=d*.3;
        if (a < Math.abs(c)) {
            a=c;
            var s=p/4;
        }
        else var s = p/(2*Math.PI) * Math.asin (c/a);
        return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
    },
    easeOutElastic: function (x, t, b, c, d) {
        var s=1.70158;
        var p=0;
        var a=c;
        if (t==0) return b;
        if ((t/=d)==1) return b+c;
        if (!p) p=d*.3;
        if (a < Math.abs(c)) {
            a=c;
            var s=p/4;
        }
        else var s = p/(2*Math.PI) * Math.asin (c/a);
        return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;
    },
    easeInOutElastic: function (x, t, b, c, d) {
        var s=1.70158;
        var p=0;
        var a=c;
        if (t==0) return b;
        if ((t/=d/2)==2) return b+c;
        if (!p) p=d*(.3*1.5);
        if (a < Math.abs(c)) {
            a=c;
            var s=p/4;
        }
        else var s = p/(2*Math.PI) * Math.asin (c/a);
        if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
        return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
    },
    easeInBack: function (x, t, b, c, d, s) {
        if (s == undefined) s = 1.70158;
        return c*(t/=d)*t*((s+1)*t - s) + b;
    },
    easeOutBack: function (x, t, b, c, d, s) {
        if (s == undefined) s = 1.70158;
        return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
    },
    easeInOutBack: function (x, t, b, c, d, s) {
        if (s == undefined) s = 1.70158;
        if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
        return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
    },
    easeInBounce: function (x, t, b, c, d) {
        return c - jQuery.easing.easeOutBounce (x, d-t, 0, c, d) + b;
    },
    easeOutBounce: function (x, t, b, c, d) {
        if ((t/=d) < (1/2.75)) {
            return c*(7.5625*t*t) + b;
        } else if (t < (2/2.75)) {
            return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
        } else if (t < (2.5/2.75)) {
            return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
        } else {
            return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
        }
    },
    easeInOutBounce: function (x, t, b, c, d) {
        if (t < d/2) return jQuery.easing.easeInBounce (x, t*2, 0, c, d) * .5 + b;
        return jQuery.easing.easeOutBounce (x, t*2-d, 0, c, d) * .5 + c*.5 + b;
    }
});

/*
 *
 * TERMS OF USE - EASING EQUATIONS
 * 
 * Open source under the BSD License. 
 * 
 * Copyright © 2001 Robert Penner
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 */
 
/*! jQuery UI - v1.8.21 - 2012-06-05
* https://github.com/jquery/jquery-ui
* Includes: jquery.ui.core.js
* Copyright (c) 2012 AUTHORS.txt; Licensed MIT, GPL */
;
(function(a,b){
    function c(b,c){
        var e=b.nodeName.toLowerCase();
        if("area"===e){
            var f=b.parentNode,g=f.name,h;
            return!b.href||!g||f.nodeName.toLowerCase()!=="map"?!1:(h=a("img[usemap=#"+g+"]")[0],!!h&&d(h))
        }
        return(/input|select|textarea|button|object/.test(e)?!b.disabled:"a"==e?b.href||c:c)&&d(b)
    }
    function d(b){
        return!a(b).parents().andSelf().filter(function(){
            return a.curCSS(this,"visibility")==="hidden"||a.expr.filters.hidden(this)
        }).length
    }
    a.ui=a.ui||{};

    if(a.ui.version)return;
    a.extend(a.ui,{
        version:"1.8.21",
        keyCode:{
            ALT:18,
            BACKSPACE:8,
            CAPS_LOCK:20,
            COMMA:188,
            COMMAND:91,
            COMMAND_LEFT:91,
            COMMAND_RIGHT:93,
            CONTROL:17,
            DELETE:46,
            DOWN:40,
            END:35,
            ENTER:13,
            ESCAPE:27,
            HOME:36,
            INSERT:45,
            LEFT:37,
            MENU:93,
            NUMPAD_ADD:107,
            NUMPAD_DECIMAL:110,
            NUMPAD_DIVIDE:111,
            NUMPAD_ENTER:108,
            NUMPAD_MULTIPLY:106,
            NUMPAD_SUBTRACT:109,
            PAGE_DOWN:34,
            PAGE_UP:33,
            PERIOD:190,
            RIGHT:39,
            SHIFT:16,
            SPACE:32,
            TAB:9,
            UP:38,
            WINDOWS:91
        }
    }),a.fn.extend({
        propAttr:a.fn.prop||a.fn.attr,
        _focus:a.fn.focus,
        focus:function(b,c){
            return typeof b=="number"?this.each(function(){
                var d=this;
                setTimeout(function(){
                    a(d).focus(),c&&c.call(d)
                },b)
            }):this._focus.apply(this,arguments)
        },
        scrollParent:function(){
            var b;
            return a.browser.msie&&/(static|relative)/.test(this.css("position"))||/absolute/.test(this.css("position"))?b=this.parents().filter(function(){
                return/(relative|absolute|fixed)/.test(a.curCSS(this,"position",1))&&/(auto|scroll)/.test(a.curCSS(this,"overflow",1)+a.curCSS(this,"overflow-y",1)+a.curCSS(this,"overflow-x",1))
            }).eq(0):b=this.parents().filter(function(){
                return/(auto|scroll)/.test(a.curCSS(this,"overflow",1)+a.curCSS(this,"overflow-y",1)+a.curCSS(this,"overflow-x",1))
            }).eq(0),/fixed/.test(this.css("position"))||!b.length?a(document):b
        },
        zIndex:function(c){
            if(c!==b)return this.css("zIndex",c);
            if(this.length){
                var d=a(this[0]),e,f;
                while(d.length&&d[0]!==document){
                    e=d.css("position");
                    if(e==="absolute"||e==="relative"||e==="fixed"){
                        f=parseInt(d.css("zIndex"),10);
                        if(!isNaN(f)&&f!==0)return f
                    }
                    d=d.parent()
                }
            }
            return 0
        },
        disableSelection:function(){
            return this.bind((a.support.selectstart?"selectstart":"mousedown")+".ui-disableSelection",function(a){
                a.preventDefault()
            })
        },
        enableSelection:function(){
            return this.unbind(".ui-disableSelection")
        }
    }),a.each(["Width","Height"],function(c,d){
        function h(b,c,d,f){
            return a.each(e,function(){
                c-=parseFloat(a.curCSS(b,"padding"+this,!0))||0,d&&(c-=parseFloat(a.curCSS(b,"border"+this+"Width",!0))||0),f&&(c-=parseFloat(a.curCSS(b,"margin"+this,!0))||0)
            }),c
        }
        var e=d==="Width"?["Left","Right"]:["Top","Bottom"],f=d.toLowerCase(),g={
            innerWidth:a.fn.innerWidth,
            innerHeight:a.fn.innerHeight,
            outerWidth:a.fn.outerWidth,
            outerHeight:a.fn.outerHeight
        };

        a.fn["inner"+d]=function(c){
            return c===b?g["inner"+d].call(this):this.each(function(){
                a(this).css(f,h(this,c)+"px")
            })
        },a.fn["outer"+d]=function(b,c){
            return typeof b!="number"?g["outer"+d].call(this,b):this.each(function(){
                a(this).css(f,h(this,b,!0,c)+"px")
            })
        }
    }),a.extend(a.expr[":"],{
        data:function(b,c,d){
            return!!a.data(b,d[3])
        },
        focusable:function(b){
            return c(b,!isNaN(a.attr(b,"tabindex")))
        },
        tabbable:function(b){
            var d=a.attr(b,"tabindex"),e=isNaN(d);
            return(e||d>=0)&&c(b,!e)
        }
    }),a(function(){
        var b=document.body,c=b.appendChild(c=document.createElement("div"));
        c.offsetHeight,a.extend(c.style,{
            minHeight:"100px",
            height:"auto",
            padding:0,
            borderWidth:0
        }),a.support.minHeight=c.offsetHeight===100,a.support.selectstart="onselectstart"in c,b.removeChild(c).style.display="none"
    }),a.extend(a.ui,{
        plugin:{
            add:function(b,c,d){
                var e=a.ui[b].prototype;
                for(var f in d)e.plugins[f]=e.plugins[f]||[],e.plugins[f].push([c,d[f]])
            },
            call:function(a,b,c){
                var d=a.plugins[b];
                if(!d||!a.element[0].parentNode)return;
                for(var e=0;e<d.length;e++)a.options[d[e][0]]&&d[e][1].apply(a.element,c)
            }
        },
        contains:function(a,b){
            return document.compareDocumentPosition?a.compareDocumentPosition(b)&16:a!==b&&a.contains(b)
        },
        hasScroll:function(b,c){
            if(a(b).css("overflow")==="hidden")return!1;
            var d=c&&c==="left"?"scrollLeft":"scrollTop",e=!1;
            return b[d]>0?!0:(b[d]=1,e=b[d]>0,b[d]=0,e)
        },
        isOverAxis:function(a,b,c){
            return a>b&&a<b+c
        },
        isOver:function(b,c,d,e,f,g){
            return a.ui.isOverAxis(b,d,f)&&a.ui.isOverAxis(c,e,g)
        }
    })
})(jQuery);
;/*! jQuery UI - v1.8.21 - 2012-06-05
* https://github.com/jquery/jquery-ui
* Includes: jquery.ui.widget.js
* Copyright (c) 2012 AUTHORS.txt; Licensed MIT, GPL */
;
(function(a,b){
    if(a.cleanData){
        var c=a.cleanData;
        a.cleanData=function(b){
            for(var d=0,e;(e=b[d])!=null;d++)try{
                a(e).triggerHandler("remove")
            }catch(f){}
            c(b)
        }
    }else{
        var d=a.fn.remove;
        a.fn.remove=function(b,c){
            return this.each(function(){
                return c||(!b||a.filter(b,[this]).length)&&a("*",this).add([this]).each(function(){
                    try{
                        a(this).triggerHandler("remove")
                    }catch(b){}
                }),d.call(a(this),b,c)
            })
        }
    }
    a.widget=function(b,c,d){
        var e=b.split(".")[0],f;
        b=b.split(".")[1],f=e+"-"+b,d||(d=c,c=a.Widget),a.expr[":"][f]=function(c){
            return!!a.data(c,b)
        },a[e]=a[e]||{},a[e][b]=function(a,b){
            arguments.length&&this._createWidget(a,b)
        };

        var g=new c;
        g.options=a.extend(!0,{},g.options),a[e][b].prototype=a.extend(!0,g,{
            namespace:e,
            widgetName:b,
            widgetEventPrefix:a[e][b].prototype.widgetEventPrefix||b,
            widgetBaseClass:f
        },d),a.widget.bridge(b,a[e][b])
    },a.widget.bridge=function(c,d){
        a.fn[c]=function(e){
            var f=typeof e=="string",g=Array.prototype.slice.call(arguments,1),h=this;
            return e=!f&&g.length?a.extend.apply(null,[!0,e].concat(g)):e,f&&e.charAt(0)==="_"?h:(f?this.each(function(){
                var d=a.data(this,c),f=d&&a.isFunction(d[e])?d[e].apply(d,g):d;
                if(f!==d&&f!==b)return h=f,!1
            }):this.each(function(){
                var b=a.data(this,c);
                b?b.option(e||{})._init():a.data(this,c,new d(e,this))
            }),h)
        }
    },a.Widget=function(a,b){
        arguments.length&&this._createWidget(a,b)
    },a.Widget.prototype={
        widgetName:"widget",
        widgetEventPrefix:"",
        options:{
            disabled:!1
        },
        _createWidget:function(b,c){
            a.data(c,this.widgetName,this),this.element=a(c),this.options=a.extend(!0,{},this.options,this._getCreateOptions(),b);
            var d=this;
            this.element.bind("remove."+this.widgetName,function(){
                d.destroy()
            }),this._create(),this._trigger("create"),this._init()
        },
        _getCreateOptions:function(){
            return a.metadata&&a.metadata.get(this.element[0])[this.widgetName]
        },
        _create:function(){},
        _init:function(){},
        destroy:function(){
            this.element.unbind("."+this.widgetName).removeData(this.widgetName),this.widget().unbind("."+this.widgetName).removeAttr("aria-disabled").removeClass(this.widgetBaseClass+"-disabled "+"ui-state-disabled")
        },
        widget:function(){
            return this.element
        },
        option:function(c,d){
            var e=c;
            if(arguments.length===0)return a.extend({},this.options);
            if(typeof c=="string"){
                if(d===b)return this.options[c];
                e={},e[c]=d
            }
            return this._setOptions(e),this
        },
        _setOptions:function(b){
            var c=this;
            return a.each(b,function(a,b){
                c._setOption(a,b)
            }),this
        },
        _setOption:function(a,b){
            return this.options[a]=b,a==="disabled"&&this.widget()[b?"addClass":"removeClass"](this.widgetBaseClass+"-disabled"+" "+"ui-state-disabled").attr("aria-disabled",b),this
        },
        enable:function(){
            return this._setOption("disabled",!1)
        },
        disable:function(){
            return this._setOption("disabled",!0)
        },
        _trigger:function(b,c,d){
            var e,f,g=this.options[b];
            d=d||{},c=a.Event(c),c.type=(b===this.widgetEventPrefix?b:this.widgetEventPrefix+b).toLowerCase(),c.target=this.element[0],f=c.originalEvent;
            if(f)for(e in f)e in c||(c[e]=f[e]);return this.element.trigger(c,d),!(a.isFunction(g)&&g.call(this.element[0],c,d)===!1||c.isDefaultPrevented())
        }
    }
})(jQuery);
;/*! jQuery UI - v1.8.21 - 2012-06-05
* https://github.com/jquery/jquery-ui
* Includes: jquery.ui.mouse.js
* Copyright (c) 2012 AUTHORS.txt; Licensed MIT, GPL */
;
(function(a,b){
    var c=!1;
    a(document).mouseup(function(a){
        c=!1
    }),a.widget("ui.mouse",{
        options:{
            cancel:":input,option",
            distance:1,
            delay:0
        },
        _mouseInit:function(){
            var b=this;
            this.element.bind("mousedown."+this.widgetName,function(a){
                return b._mouseDown(a)
            }).bind("click."+this.widgetName,function(c){
                if(!0===a.data(c.target,b.widgetName+".preventClickEvent"))return a.removeData(c.target,b.widgetName+".preventClickEvent"),c.stopImmediatePropagation(),!1
            }),this.started=!1
        },
        _mouseDestroy:function(){
            this.element.unbind("."+this.widgetName),a(document).unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate)
        },
        _mouseDown:function(b){
            if(c)return;
            this._mouseStarted&&this._mouseUp(b),this._mouseDownEvent=b;
            var d=this,e=b.which==1,f=typeof this.options.cancel=="string"&&b.target.nodeName?a(b.target).closest(this.options.cancel).length:!1;
            if(!e||f||!this._mouseCapture(b))return!0;
            this.mouseDelayMet=!this.options.delay,this.mouseDelayMet||(this._mouseDelayTimer=setTimeout(function(){
                d.mouseDelayMet=!0
            },this.options.delay));
            if(this._mouseDistanceMet(b)&&this._mouseDelayMet(b)){
                this._mouseStarted=this._mouseStart(b)!==!1;
                if(!this._mouseStarted)return b.preventDefault(),!0
            }
            return!0===a.data(b.target,this.widgetName+".preventClickEvent")&&a.removeData(b.target,this.widgetName+".preventClickEvent"),this._mouseMoveDelegate=function(a){
                return d._mouseMove(a)
            },this._mouseUpDelegate=function(a){
                return d._mouseUp(a)
            },a(document).bind("mousemove."+this.widgetName,this._mouseMoveDelegate).bind("mouseup."+this.widgetName,this._mouseUpDelegate),b.preventDefault(),c=!0,!0
        },
        _mouseMove:function(b){
            return!a.browser.msie||document.documentMode>=9||!!b.button?this._mouseStarted?(this._mouseDrag(b),b.preventDefault()):(this._mouseDistanceMet(b)&&this._mouseDelayMet(b)&&(this._mouseStarted=this._mouseStart(this._mouseDownEvent,b)!==!1,this._mouseStarted?this._mouseDrag(b):this._mouseUp(b)),!this._mouseStarted):this._mouseUp(b)
        },
        _mouseUp:function(b){
            return a(document).unbind("mousemove."+this.widgetName,this._mouseMoveDelegate).unbind("mouseup."+this.widgetName,this._mouseUpDelegate),this._mouseStarted&&(this._mouseStarted=!1,b.target==this._mouseDownEvent.target&&a.data(b.target,this.widgetName+".preventClickEvent",!0),this._mouseStop(b)),!1
        },
        _mouseDistanceMet:function(a){
            return Math.max(Math.abs(this._mouseDownEvent.pageX-a.pageX),Math.abs(this._mouseDownEvent.pageY-a.pageY))>=this.options.distance
        },
        _mouseDelayMet:function(a){
            return this.mouseDelayMet
        },
        _mouseStart:function(a){},
        _mouseDrag:function(a){},
        _mouseStop:function(a){},
        _mouseCapture:function(a){
            return!0
        }
    })
})(jQuery);
;/*! jQuery UI - v1.8.21 - 2012-06-05
* https://github.com/jquery/jquery-ui
* Includes: jquery.ui.slider.js
* Copyright (c) 2012 AUTHORS.txt; Licensed MIT, GPL */
;
(function(a,b){
    var c=5;
    a.widget("ui.slider",a.ui.mouse,{
        widgetEventPrefix:"slide",
        options:{
            animate:!1,
            distance:0,
            max:100,
            min:0,
            orientation:"horizontal",
            range:!1,
            step:1,
            value:0,
            values:null
        },
        _create:function(){
            var b=this,d=this.options,e=this.element.find(".ui-slider-handle").addClass("ui-state-default ui-corner-all"),f="<a class='ui-slider-handle ui-state-default ui-corner-all' href='#'></a>",g=d.values&&d.values.length||1,h=[];
            this._keySliding=!1,this._mouseSliding=!1,this._animateOff=!0,this._handleIndex=null,this._detectOrientation(),this._mouseInit(),this.element.addClass("ui-slider ui-slider-"+this.orientation+" ui-widget"+" ui-widget-content"+" ui-corner-all"+(d.disabled?" ui-slider-disabled ui-disabled":"")),this.range=a([]),d.range&&(d.range===!0&&(d.values||(d.values=[this._valueMin(),this._valueMin()]),d.values.length&&d.values.length!==2&&(d.values=[d.values[0],d.values[0]])),this.range=a("<div></div>").appendTo(this.element).addClass("ui-slider-range ui-widget-header"+(d.range==="min"||d.range==="max"?" ui-slider-range-"+d.range:"")));
            for(var i=e.length;i<g;i+=1)h.push(f);
            this.handles=e.add(a(h.join("")).appendTo(b.element)),this.handle=this.handles.eq(0),this.handles.add(this.range).filter("a").click(function(a){
                a.preventDefault()
            }).hover(function(){
                d.disabled||a(this).addClass("ui-state-hover")
            },function(){
                a(this).removeClass("ui-state-hover")
            }).focus(function(){
                d.disabled?a(this).blur():(a(".ui-slider .ui-state-focus").removeClass("ui-state-focus"),a(this).addClass("ui-state-focus"))
            }).blur(function(){
                a(this).removeClass("ui-state-focus")
            }),this.handles.each(function(b){
                a(this).data("index.ui-slider-handle",b)
            }),this.handles.keydown(function(d){
                var e=a(this).data("index.ui-slider-handle"),f,g,h,i;
                if(b.options.disabled)return;
                switch(d.keyCode){
                    case a.ui.keyCode.HOME:case a.ui.keyCode.END:case a.ui.keyCode.PAGE_UP:case a.ui.keyCode.PAGE_DOWN:case a.ui.keyCode.UP:case a.ui.keyCode.RIGHT:case a.ui.keyCode.DOWN:case a.ui.keyCode.LEFT:
                        d.preventDefault();
                        if(!b._keySliding){
                            b._keySliding=!0,a(this).addClass("ui-state-active"),f=b._start(d,e);
                            if(f===!1)return
                        }
                }
                i=b.options.step,b.options.values&&b.options.values.length?g=h=b.values(e):g=h=b.value();
                switch(d.keyCode){
                    case a.ui.keyCode.HOME:
                        h=b._valueMin();
                        break;
                    case a.ui.keyCode.END:
                        h=b._valueMax();
                        break;
                    case a.ui.keyCode.PAGE_UP:
                        h=b._trimAlignValue(g+(b._valueMax()-b._valueMin())/c);
                        break;
                    case a.ui.keyCode.PAGE_DOWN:
                        h=b._trimAlignValue(g-(b._valueMax()-b._valueMin())/c);
                        break;
                    case a.ui.keyCode.UP:case a.ui.keyCode.RIGHT:
                        if(g===b._valueMax())return;
                        h=b._trimAlignValue(g+i);
                        break;
                    case a.ui.keyCode.DOWN:case a.ui.keyCode.LEFT:
                        if(g===b._valueMin())return;
                        h=b._trimAlignValue(g-i)
                }
                b._slide(d,e,h)
            }).keyup(function(c){
                var d=a(this).data("index.ui-slider-handle");
                b._keySliding&&(b._keySliding=!1,b._stop(c,d),b._change(c,d),a(this).removeClass("ui-state-active"))
            }),this._refreshValue(),this._animateOff=!1
        },
        destroy:function(){
            return this.handles.remove(),this.range.remove(),this.element.removeClass("ui-slider ui-slider-horizontal ui-slider-vertical ui-slider-disabled ui-widget ui-widget-content ui-corner-all").removeData("slider").unbind(".slider"),this._mouseDestroy(),this
        },
        _mouseCapture:function(b){
            var c=this.options,d,e,f,g,h,i,j,k,l;
            return c.disabled?!1:(this.elementSize={
                width:this.element.outerWidth(),
                height:this.element.outerHeight()
            },this.elementOffset=this.element.offset(),d={
                x:b.pageX,
                y:b.pageY
            },e=this._normValueFromMouse(d),f=this._valueMax()-this._valueMin()+1,h=this,this.handles.each(function(b){
                var c=Math.abs(e-h.values(b));
                f>c&&(f=c,g=a(this),i=b)
            }),c.range===!0&&this.values(1)===c.min&&(i+=1,g=a(this.handles[i])),j=this._start(b,i),j===!1?!1:(this._mouseSliding=!0,h._handleIndex=i,g.addClass("ui-state-active").focus(),k=g.offset(),l=!a(b.target).parents().andSelf().is(".ui-slider-handle"),this._clickOffset=l?{
                left:0,
                top:0
            }:{
                left:b.pageX-k.left-g.width()/2,
                top:b.pageY-k.top-g.height()/2-(parseInt(g.css("borderTopWidth"),10)||0)-(parseInt(g.css("borderBottomWidth"),10)||0)+(parseInt(g.css("marginTop"),10)||0)
            },this.handles.hasClass("ui-state-hover")||this._slide(b,i,e),this._animateOff=!0,!0))
        },
        _mouseStart:function(a){
            return!0
        },
        _mouseDrag:function(a){
            var b={
                x:a.pageX,
                y:a.pageY
            },c=this._normValueFromMouse(b);
            return this._slide(a,this._handleIndex,c),!1
        },
        _mouseStop:function(a){
            return this.handles.removeClass("ui-state-active"),this._mouseSliding=!1,this._stop(a,this._handleIndex),this._change(a,this._handleIndex),this._handleIndex=null,this._clickOffset=null,this._animateOff=!1,!1
        },
        _detectOrientation:function(){
            this.orientation=this.options.orientation==="vertical"?"vertical":"horizontal"
        },
        _normValueFromMouse:function(a){
            var b,c,d,e,f;
            return this.orientation==="horizontal"?(b=this.elementSize.width,c=a.x-this.elementOffset.left-(this._clickOffset?this._clickOffset.left:0)):(b=this.elementSize.height,c=a.y-this.elementOffset.top-(this._clickOffset?this._clickOffset.top:0)),d=c/b,d>1&&(d=1),d<0&&(d=0),this.orientation==="vertical"&&(d=1-d),e=this._valueMax()-this._valueMin(),f=this._valueMin()+d*e,this._trimAlignValue(f)
        },
        _start:function(a,b){
            var c={
                handle:this.handles[b],
                value:this.value()
            };

            return this.options.values&&this.options.values.length&&(c.value=this.values(b),c.values=this.values()),this._trigger("start",a,c)
        },
        _slide:function(a,b,c){
            var d,e,f;
            this.options.values&&this.options.values.length?(d=this.values(b?0:1),this.options.values.length===2&&this.options.range===!0&&(b===0&&c>d||b===1&&c<d)&&(c=d),c!==this.values(b)&&(e=this.values(),e[b]=c,f=this._trigger("slide",a,{
                handle:this.handles[b],
                value:c,
                values:e
            }),d=this.values(b?0:1),f!==!1&&this.values(b,c,!0))):c!==this.value()&&(f=this._trigger("slide",a,{
                handle:this.handles[b],
                value:c
            }),f!==!1&&this.value(c))
        },
        _stop:function(a,b){
            var c={
                handle:this.handles[b],
                value:this.value()
            };

            this.options.values&&this.options.values.length&&(c.value=this.values(b),c.values=this.values()),this._trigger("stop",a,c)
        },
        _change:function(a,b){
            if(!this._keySliding&&!this._mouseSliding){
                var c={
                    handle:this.handles[b],
                    value:this.value()
                };

                this.options.values&&this.options.values.length&&(c.value=this.values(b),c.values=this.values()),this._trigger("change",a,c)
            }
        },
        value:function(a){
            if(arguments.length){
                this.options.value=this._trimAlignValue(a),this._refreshValue(),this._change(null,0);
                return
            }
            return this._value()
        },
        values:function(b,c){
            var d,e,f;
            if(arguments.length>1){
                this.options.values[b]=this._trimAlignValue(c),this._refreshValue(),this._change(null,b);
                return
            }
            if(!arguments.length)return this._values();
            if(!a.isArray(arguments[0]))return this.options.values&&this.options.values.length?this._values(b):this.value();
            d=this.options.values,e=arguments[0];
            for(f=0;f<d.length;f+=1)d[f]=this._trimAlignValue(e[f]),this._change(null,f);
            this._refreshValue()
        },
        _setOption:function(b,c){
            var d,e=0;
            a.isArray(this.options.values)&&(e=this.options.values.length),a.Widget.prototype._setOption.apply(this,arguments);
            switch(b){
                case"disabled":
                    c?(this.handles.filter(".ui-state-focus").blur(),this.handles.removeClass("ui-state-hover"),this.handles.propAttr("disabled",!0),this.element.addClass("ui-disabled")):(this.handles.propAttr("disabled",!1),this.element.removeClass("ui-disabled"));
                    break;
                case"orientation":
                    this._detectOrientation(),this.element.removeClass("ui-slider-horizontal ui-slider-vertical").addClass("ui-slider-"+this.orientation),this._refreshValue();
                    break;
                case"value":
                    this._animateOff=!0,this._refreshValue(),this._change(null,0),this._animateOff=!1;
                    break;
                case"values":
                    this._animateOff=!0,this._refreshValue();
                    for(d=0;d<e;d+=1)this._change(null,d);
                    this._animateOff=!1
            }
        },
        _value:function(){
            var a=this.options.value;
            return a=this._trimAlignValue(a),a
        },
        _values:function(a){
            var b,c,d;
            if(arguments.length)return b=this.options.values[a],b=this._trimAlignValue(b),b;
            c=this.options.values.slice();
            for(d=0;d<c.length;d+=1)c[d]=this._trimAlignValue(c[d]);
            return c
        },
        _trimAlignValue:function(a){
            if(a<=this._valueMin())return this._valueMin();
            if(a>=this._valueMax())return this._valueMax();
            var b=this.options.step>0?this.options.step:1,c=(a-this._valueMin())%b,d=a-c;
            return Math.abs(c)*2>=b&&(d+=c>0?b:-b),parseFloat(d.toFixed(5))
        },
        _valueMin:function(){
            return this.options.min
        },
        _valueMax:function(){
            return this.options.max
        },
        _refreshValue:function(){
            var b=this.options.range,c=this.options,d=this,e=this._animateOff?!1:c.animate,f,g={},h,i,j,k;
            this.options.values&&this.options.values.length?this.handles.each(function(b,i){
                f=(d.values(b)-d._valueMin())/(d._valueMax()-d._valueMin())*100,g[d.orientation==="horizontal"?"left":"bottom"]=f+"%",a(this).stop(1,1)[e?"animate":"css"](g,c.animate),d.options.range===!0&&(d.orientation==="horizontal"?(b===0&&d.range.stop(1,1)[e?"animate":"css"]({
                    left:f+"%"
                },c.animate),b===1&&d.range[e?"animate":"css"]({
                    width:f-h+"%"
                },{
                    queue:!1,
                    duration:c.animate
                })):(b===0&&d.range.stop(1,1)[e?"animate":"css"]({
                    bottom:f+"%"
                },c.animate),b===1&&d.range[e?"animate":"css"]({
                    height:f-h+"%"
                },{
                    queue:!1,
                    duration:c.animate
                }))),h=f
            }):(i=this.value(),j=this._valueMin(),k=this._valueMax(),f=k!==j?(i-j)/(k-j)*100:0,g[d.orientation==="horizontal"?"left":"bottom"]=f+"%",this.handle.stop(1,1)[e?"animate":"css"](g,c.animate),b==="min"&&this.orientation==="horizontal"&&this.range.stop(1,1)[e?"animate":"css"]({
                width:f+"%"
            },c.animate),b==="max"&&this.orientation==="horizontal"&&this.range[e?"animate":"css"]({
                width:100-f+"%"
            },{
                queue:!1,
                duration:c.animate
            }),b==="min"&&this.orientation==="vertical"&&this.range.stop(1,1)[e?"animate":"css"]({
                height:f+"%"
            },c.animate),b==="max"&&this.orientation==="vertical"&&this.range[e?"animate":"css"]({
                height:100-f+"%"
            },{
                queue:!1,
                duration:c.animate
            }))
        }
    }),a.extend(a.ui.slider,{
        version:"1.8.21"
    })
})(jQuery);
;

/*
* jQuery UI Touch Punch 0.2.2
*
* Copyright 2011, Dave Furfero
* Dual licensed under the MIT or GPL Version 2 licenses.
*
* Depends:
* jquery.ui.widget.js
* jquery.ui.mouse.js
*/
;(function(b){b.support.touch="ontouchend" in document;if(!b.support.touch){return;}var c=b.ui.mouse.prototype,e=c._mouseInit,a;function d(g,h){if(g.originalEvent.touches.length>1){return;}g.preventDefault();var i=g.originalEvent.changedTouches[0],f=document.createEvent("MouseEvents");f.initMouseEvent(h,true,true,window,1,i.screenX,i.screenY,i.clientX,i.clientY,false,false,false,false,0,null);g.target.dispatchEvent(f);}c._touchStart=function(g){var f=this;if(a||!f._mouseCapture(g.originalEvent.changedTouches[0])){return;}a=true;f._touchMoved=false;d(g,"mouseover");d(g,"mousemove");d(g,"mousedown");};c._touchMove=function(f){if(!a){return;}this._touchMoved=true;d(f,"mousemove");};c._touchEnd=function(f){if(!a){return;}d(f,"mouseup");d(f,"mouseout");if(!this._touchMoved){d(f,"click");}a=false;};c._mouseInit=function(){var f=this;f.element.bind("touchstart",b.proxy(f,"_touchStart")).bind("touchmove",b.proxy(f,"_touchMove")).bind("touchend",b.proxy(f,"_touchEnd"));e.call(f);};})(jQuery);



/**
* hoverIntent r6 // 2011.02.26 // jQuery 1.5.1+
* <http://cherne.net/brian/resources/jquery.hoverIntent.html>
*
* @param  f  onMouseOver function || An object with configuration options
* @param  g  onMouseOut function  || Nothing (use configuration options object)
* @author    Brian Cherne brian(at)cherne(dot)net
*/
(function($){
    $.fn.hoverIntent=function(f,g){
        var cfg={
            sensitivity:7,
            interval:100,
            timeout:0
        };

        cfg=$.extend(cfg,g?{
            over:f,
            out:g
        }:f);
        var cX,cY,pX,pY;
        var track=function(ev){
            cX=ev.pageX;
            cY=ev.pageY
        };

        var compare=function(ev,ob){
            ob.hoverIntent_t=clearTimeout(ob.hoverIntent_t);
            if((Math.abs(pX-cX)+Math.abs(pY-cY))<cfg.sensitivity){
                $(ob).unbind("mousemove",track);
                ob.hoverIntent_s=1;
                return cfg.over.apply(ob,[ev])
            }else{
                pX=cX;
                pY=cY;
                ob.hoverIntent_t=setTimeout(function(){
                    compare(ev,ob)
                },cfg.interval)
            }
        };

        var delay=function(ev,ob){
            ob.hoverIntent_t=clearTimeout(ob.hoverIntent_t);
            ob.hoverIntent_s=0;
            return cfg.out.apply(ob,[ev])
        };

        var handleHover=function(e){
            var ev=jQuery.extend({},e);
            var ob=this;
            if(ob.hoverIntent_t){
                ob.hoverIntent_t=clearTimeout(ob.hoverIntent_t)
            }
            if(e.type=="mouseenter"){
                pX=ev.pageX;
                pY=ev.pageY;
                $(ob).bind("mousemove",track);
                if(ob.hoverIntent_s!=1){
                    ob.hoverIntent_t=setTimeout(function(){
                        compare(ev,ob)
                    },cfg.interval)
                }
            }else{
                $(ob).unbind("mousemove",track);
                if(ob.hoverIntent_s==1){
                    ob.hoverIntent_t=setTimeout(function(){
                        delay(ev,ob)
                    },cfg.timeout)
                }
            }
        };

        return this.bind('mouseenter',handleHover).bind('mouseleave',handleHover)
    }
})(jQuery);