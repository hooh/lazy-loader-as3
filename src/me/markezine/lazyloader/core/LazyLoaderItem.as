/**
 * Licensed under the MIT License and Creative Commons 3.0 BY-SA
 * 
 * Copyright (c) 2011 The LazyLoader Team
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS CREATIVE COMMONS PUBLIC 
 * LICENSE ("CCPL" OR "LICENSE"). THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. 
 * ANY USE OF THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
 * PROHIBITED.
 * BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO BE BOUND BY THE 
 * TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE MAY BE CONSIDERED TO BE A CONTRACT, THE 
 * LICENSOR GRANTS YOU THE RIGHTS CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH 
 * TERMS AND CONDITIONS.
 * 
 * http://creativecommons.org/licenses/by-sa/3.0/legalcode
 *  
 * http://code.google.com/p/lazy-loader-as3
 * 
 * @author João Paulo Marquesini (markezine)
 * 
 */

package me.markezine.lazyloader.core {
	import flash.display.Loader;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.events.LazyLoaderMediaEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	[Event(name="init", type="flash.events.Event")]
	[Event(name="unload", type="flash.events.Event")]
	[Event(name="id3", type="flash.events.Event")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="asyncError", type="flash.events.AsyncErrorEvent")]
	[Event(name="netStatus", type="flash.events.NetStatusEvent")]
	[Event(name="sampleData", type="flash.events.SampleDataEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="open", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="size_complete", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="complete", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="progress", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="canceled", type="me.markezine.lazyloader.events.LazyLoaderEvent")]
	[Event(name="metadataReceived", type="me.markezine.lazyloader.events.LazyLoaderMediaEvent")]
	[Event(name="bufferFull", type="me.markezine.lazyloader.events.LazyLoaderMediaEvent")]
	[Event(name="lazyloaderError", type="me.markezine.lazyloader.events.LazyLoaderErrorEvent")]
	
	/**
	 * The LazyLoaderItem class is a universal loading class for all types of data.
	 * It can be used in the <code>LazyLoader</code> queue, or can be used by itself to load 
	 * a single file.
	 * @param request The request to be loaded. It can be either a <code>URLRequest</code> or a
	 * string containing the url of the file to be loaded.
	 * @param attributes Attributes that can specified to add special parameters to the loading 
	 * process. There is a <code>LazyLoaderVariables</code> class with the default parameters 
	 * that you can use to create items as well.
	 * 
	 */
	public class LazyLoaderItem extends EventDispatcher
	{  
		internal var instance:String;
		internal var uniqueId:String;
		
		private var _request:URLRequest;
		private var _params:Object;
		private var _context:Object;
		private var _type:String;
		private var _loader:ICustomLoader;
		private var _bytesTotal:uint = 0;
		private var _relativeUrl:String = "";
		private var _absoluteUrl:String = "";
		private var _useAbsoluteURL:Boolean = true;
		private var listeners:Dictionary;
		
		/**
		 * The LazyLoaderItem class is a universal loading class for all types of data.
		 * It can be used in the <code>LazyLoader</code> queue, or can be used by itself to load 
		 * a single file.
		 * @param request The request to be loaded. It can be either a <code>URLRequest</code> or a
		 * string containing the url of the file to be loaded.
		 * @param attributes Attributes that can specified to add special parameters to the loading 
		 * process. There is a <code>LazyLoaderVariables</code> class with the default parameters 
		 * that you can use to create items as well.
		 * 
		 */
		public function LazyLoaderItem(request:Object, params:Object=null)
		{
			if (!params) params = {};
			if (params is String) params = {id:params};
			if(params is LazyLoaderVariables) params = LazyLoaderVariables(params).toObject();
			_context = params.context;
			_request = LazyLoaderUtils.getRequest(request);
			_relativeUrl = _request.url;
			_absoluteUrl = LazyLoaderUtils.getAbsoluteUrl(_relativeUrl);
			_type = LazyLoaderUtils.getItemType(params.forceType || _request.url);
			_loader = LazyLoaderUtils.createLoader(_type);
			listeners = new Dictionary();
			_params = params;
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			switch(type){
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case Event.ID3:
				case Event.COMPLETE:
				case ProgressEvent.PROGRESS:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case AsyncErrorEvent.ASYNC_ERROR:
				case NetStatusEvent.NET_STATUS:
				case SampleDataEvent.SAMPLE_DATA:
				case SecurityErrorEvent.SECURITY_ERROR:
				case LazyLoaderErrorEvent.LAZYLOADER_ERROR:
				case LazyLoaderEvent.CANCELED:
				case LazyLoaderMediaEvent.METADATA_RECEIVED:
				case LazyLoaderMediaEvent.BUFFER_FULL:
					_loader.addEventListener(type, dispatchEvent, useCapture, priority, useWeakReference);
				break;
			}
			
			if(!listeners[type]) {
				listeners[type] = [listener];
			}else{
				listeners[type].push(listener);
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			if(listeners[type] && listeners[type].indexOf(listener) > -1){
				listeners[type].splice(listeners[type].indexOf(listener), 1);
			}
			
			switch(type){
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case Event.ID3:
				case Event.COMPLETE:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case AsyncErrorEvent.ASYNC_ERROR:
				case NetStatusEvent.NET_STATUS:
				case SampleDataEvent.SAMPLE_DATA:
				case SecurityErrorEvent.SECURITY_ERROR:
				case ProgressEvent.PROGRESS:
				case LazyLoaderErrorEvent.LAZYLOADER_ERROR:
				case LazyLoaderEvent.CANCELED:
				case LazyLoaderMediaEvent.METADATA_RECEIVED:
				case LazyLoaderMediaEvent.BUFFER_FULL:
					if(listeners[type].length == 0) _loader.removeEventListener(type, dispatchEvent, useCapture);
					break;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		override public function dispatchEvent(event:Event):Boolean{
			switch(event.type){
				case Event.COMPLETE:
				case ProgressEvent.PROGRESS:
					return super.dispatchEvent(new LazyLoaderEvent(event.type, _loader.loaded, bytesTotal, event.bubbles, event.cancelable));
					break;
				
				default:
					return super.dispatchEvent(event);
					break;
			}
		}
		
		/** 
		 * This method can be used to retrieve the size of the file before loading it.
		 */
		public function getSize():void{
			if(bytesTotal > 0){
				dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.SIZE_COMPLETE, 0, bytesTotal));
				return;
			}
			var sizeGetter:ICustomLoader = LazyLoaderUtils.createLoader(_type);
			sizeGetter.addEventListener(ProgressEvent.PROGRESS, sizeGetterListener);
			sizeGetter.lazyLoad(_request, _context);
		}
		
		private function sizeGetterListener(event:Event):void{
			var sizeGetter:ICustomLoader = ICustomLoader(event.currentTarget);
			if(sizeGetter.total <= 0) return;
			sizeGetter.removeEventListener(ProgressEvent.PROGRESS, sizeGetterListener);
			_bytesTotal = sizeGetter.total;
			sizeGetter.close();
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.SIZE_COMPLETE, 0, bytesTotal));
		}
		
		/** 
		 * Start loading the current file.
		 */
		public function load():void{
			if(_useAbsoluteURL) _request.url = _absoluteUrl;
			if(type == ItemType.AUDIO && (_loader.status == LazyLoaderStatus.CANCELED || _loader.status == LazyLoaderStatus.ERROR)){
				var i:String;
				for(i in listeners) _loader.removeEventListener(i, dispatchEvent,listeners[i].useCapture);
				_loader = LazyLoaderUtils.createLoader(type);
				for(i in listeners) _loader.addEventListener(i, dispatchEvent,listeners[i].useCapture, listeners[i].priority, listeners[i].useWeakReference );
			}
			_loader.lazyLoad(_request, _context);
		}
		
		
		/** 
		 * Close the current load operation.
		 */
		public function close():void{
			_loader.close();
		}
		
		
		/** 
		 * Destroys the loader, killing all current process and events.
		 */
		public function destroy():void{
			_loader.destroy();
		}
		
		/**
		 * Returns the content of the item, in any format it can be. It's the same as data.
		 * @see data
		 */
		public function get content():Object{
			if(loader is URLLoader){
				return URLLoader(loader).data;
			}else if(loader is Loader){
				return Loader(loader).content;
			}else{
				return loader;
			}
		}
		
		/**
		 * Returns the loader of the item.
		 */
		public function get loader():ICustomLoader { return _loader; }
		
		/**
		 * Returns the content of the item, in any format it can be. It's the same as content.
		 * @see content
		 */
		public function get data():Object{ return content; }
		
		/** 
		 * returns a String with the type of the file.
		 * @see ItemType 
		 */
		public function get type():String{ return _type; }
		
		/** 
		 * If the item is a Sound returns the id3, if is a Netstream returns the video metadata.
		 * If none of the above, returns null. 
		 */
		public function get metadata():Object { return loader.metadata; }
		
		
		/** 
		 * The current bytes loaded of the file.
		 */
		public function get bytesLoaded():uint{return loader.loaded; }
		
		
		/**
		 *  The total bytes of the file. 
		 */
		public function get bytesTotal():uint{return Math.max(_loader.total, _bytesTotal); }

		/**
		 * The url of the file. This propertie returns the same url used in the request.
		 * @see absoluteUrl
		 */
		public function get url():String { return _relativeUrl; }

		/**
		 * The absolute url of the file.
		 * @see url
		 */
		public function get absoluteUrl():String { return _absoluteUrl; }

		/** 
		 * Used to set if the loader should use the absolute url or the relative.
		 * @default true
		 */
		public function get useAbsoluteURL():Boolean { return _useAbsoluteURL; }
		public function set useAbsoluteURL(value:Boolean):void { _useAbsoluteURL = value; }
		
		/**
		 * Returns the current status of the item.
		 * @see LazyLoaderStatus 
		 */
		public function get status():String{ return loader.status; } 
		
		internal function get params():Object{ return _params; }

	}
}