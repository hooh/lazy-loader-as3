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
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="io_error", type="flash.events.IOErrorEvent")]
	[Event(name="security_error", type="flash.events.SecurityErrorEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	public class LazyLoaderItem extends EventDispatcher
	{  
		private var _loader:Object;
		private var _type:String;
		private var _url:String;
		private var _isLoading:Boolean;
		private var _context:LoaderContext;
		private var _bytesTotal:Number=0;
		private var _bytesLoaded:Number=0;
		private var _uniqueId:String;
		private var _request:URLRequest;
		private var _useWeakReference:Boolean;
		
		public function LazyLoaderItem(request:URLRequest, uniqueId:String, params:Object=null)
		{
			if (!params) params = {};
			_context = params.context;
			if(Capabilities.playerType == "External" || Capabilities.playerType == "External"){
				_context = null;
			}
			_uniqueId = uniqueId;
			_url = request.url;
			_request = request;
			_useWeakReference = params.useWeakReference == null ? LazyLoader.useWeakReference : params.useWeakReference;
			_type = params.forceType ? getForcedType(params.forceType) : getTypeByURL(url);
		}
		
		private function getForcedType(type:String):String{
			switch(type){
				case ItemType.BITMAP:
				case ItemType.FLASH:
				case ItemType.TEXT:
				case ItemType.BINARY:
				case ItemType.AUDIO:
				case ItemType.VIDEO:
				case ItemType.AUTO:
					return type;
			}
			
			return ItemType.TEXT;
		}
		
		private function getTypeByURL(url:String):String{
			var dot_splited:Array = url.split(".");
			var extension:String = dot_splited[dot_splited.length-1];
			switch(extension){
				case "swf":
					return ItemType.FLASH;
				case "jpg":
				case "jpeg":
				case "png":
				case "gif":
					return ItemType.BITMAP;
					break;
				
				case "flv":
				case "f4v":
				case "mp4":
				case "m4a":
				case "mov":
				case "mp4v":
				case "3gp":
				case "3g2":
					return ItemType.VIDEO;
					
				case "mp3":
					return ItemType.AUDIO;
			}
			return ItemType.TEXT;
		}
		
		 
		public function get loader():Object{
			return _loader;
		}
		
		internal function get internalLoader():Object
		{
			return _loader;
		}

		internal function set internalLoader(value:Object):void
		{
			_loader = value;
		}
		
		public function get data():Object{
			if(_loader is URLLoader){
				return _loader.data;
			}else{
				throw new Error("Resource " + _url + " is not URLLoader data.");
			}
		}
		
		public function get content():DisplayObject{
			if(_loader is Loader){
				return _loader.content as DisplayObject;
			}else{
				throw new Error("Resource " + _url + " is not a DisplayObject.");
			}
		}
		
		internal function get isLoading():Boolean{
			return _isLoading;
		}
		
		internal function set isLoading(value:Boolean):void{
			_isLoading = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function get url():String
		{
			return _url;
		}

		public function get context() : LoaderContext {
			return _context;
		}

		public function get bytesTotal() : Number {
			return _bytesTotal;
		}

		public function set bytesTotal(bytesTotal : Number) : void {
			_bytesTotal = bytesTotal;
		}

		public function get bytesLoaded() : Number {
			return _bytesLoaded;
		}

		public function set bytesLoaded(bytesLoaded : Number) : void {
			_bytesLoaded = bytesLoaded;
		}

		internal function get uniqueId():String
		{
			return _uniqueId;
		}

		internal function get request():URLRequest
		{
			return _request;
		}

		internal function set request(value:URLRequest):void
		{
			_request = value;
		}

		internal function get useWeakReference():Boolean
		{
			return _useWeakReference;
		}

		internal function set useWeakReference(value:Boolean):void
		{
			_useWeakReference = value;
		}
	}
}