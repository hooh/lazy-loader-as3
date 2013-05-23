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
package me.markezine.lazyloader.core
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	internal class CustomLoader extends Loader implements ICustomLoader{
		private var request:URLRequest;
		private var _status:String = LazyLoaderStatus.WAITING;
		
		private var listeners:Dictionary;
		
		public function CustomLoader(){
			super();
			listeners = new Dictionary();
		}
		
		public function lazyLoad(request:URLRequest, context:Object=null):void{
			if(_status!=LazyLoaderStatus.WAITING && status != LazyLoaderStatus.CANCELED && status!=LazyLoaderStatus.ERROR) return;
			_status = LazyLoaderStatus.LOADING;
			if(!listeners) listeners = new Dictionary();
			this.request = request;
			if(!context) context = new LoaderContext(true, LazyLoader.defaultApplicationDomain, LazyLoader.defaultSecurityDomain);
			super.load(request, LoaderContext(context));
			addInternalHandlers();
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null):void{
			lazyLoad(request, context);
		}
		
		override public function close():void{
			if(_status != LazyLoaderStatus.LOADING && _status != LazyLoaderStatus.WAITING) return;
			_status = LazyLoaderStatus.CANCELED;
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.CANCELED, loaded, total));
			removeInternalHandlers();
			try{
			super.close();
			}catch(e:Error){}
		}
		
		public function destroy():void{
			close();
			removeInternalHandlers();
		}
		
		private function addInternalHandlers():void{
			contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, internalHandler, false, int.MAX_VALUE);
			contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler, false, int.MAX_VALUE);
			contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler, false, int.MAX_VALUE);
			contentLoaderInfo.addEventListener(Event.COMPLETE, internalHandler,false, int.MAX_VALUE);
		}
		
		private function internalHandler(event:Event):void{
			switch(event.type){
				case SecurityErrorEvent.SECURITY_ERROR:
				case IOErrorEvent.IO_ERROR:
					_status = LazyLoaderStatus.ERROR;
					dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					removeInternalHandlers();
					break;
				
				case HTTPStatusEvent.HTTP_STATUS: 
					if(HTTPStatusEvent(event).status < 200 || HTTPStatusEvent(event).status > 399){  
						dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					}
					break;
				
				case Event.COMPLETE:
					_status = LazyLoaderStatus.COMPLETE;
					removeInternalHandlers();
					break;
			}
		}
		
		private function removeInternalHandlers():void{
			contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, internalHandler);
			contentLoaderInfo.removeEventListener(Event.COMPLETE, internalHandler);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			switch(type){
				case Event.COMPLETE:
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case ProgressEvent.PROGRESS:
					contentLoaderInfo.addEventListener(type, dispatchEvent, useCapture, priority, useWeakReference);
					break;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			if(!listeners[type]){
				listeners[type] = [listener];
			}else if(listeners[type] && listeners[type].indexOf(listener) == -1){
				listeners[type].push(listener);
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			if(listeners[type] && listeners[type].indexOf(listener) > -1){
				listeners[type].splice(listeners[type].indexOf(listener), 1);
			}
			switch(type){
				case Event.COMPLETE:
				case Event.INIT:
				case Event.OPEN:
				case Event.UNLOAD:
				case HTTPStatusEvent.HTTP_STATUS:
				case IOErrorEvent.IO_ERROR:
				case ProgressEvent.PROGRESS:
					if(listeners[type].length == 0) contentLoaderInfo.removeEventListener(type, dispatchEvent, useCapture);
					break;
			}
			super.removeEventListener(type, listener, useCapture);
		}
		
		public function get bytes():ByteArray{ return contentLoaderInfo.bytes; }
		public function get loaded():uint{ return contentLoaderInfo.bytesLoaded; }
		public function get total():uint{ return contentLoaderInfo.bytesTotal; }
		public function get status():String{ return _status; }
		public function get metadata():Object{ return null };
	}
}