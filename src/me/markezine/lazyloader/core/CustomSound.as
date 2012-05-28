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
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.events.LazyLoaderMediaEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	internal class CustomSound extends Sound implements ICustomLoader{
		
		private var request:URLRequest;
		private var _status:String = LazyLoaderStatus.WAITING;
		
		public function CustomSound(){
			super(null);
		}
		
		public function lazyLoad(request:URLRequest, context:Object=null):void{
			if(_status != LazyLoaderStatus.WAITING) return;
			_status = LazyLoaderStatus.LOADING;
			this.request = request;
			super.load(request, SoundLoaderContext(context));
			addInternalHandlers();
		}
		
		override public function load(stream:URLRequest, context:SoundLoaderContext=null):void{
			if(request == null ) return;
			lazyLoad(stream, context);
		}
		
		private function addInternalHandlers():void{
			super.addEventListener(Event.ID3, internalHandler);
			super.addEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.addEventListener(Event.COMPLETE, internalHandler);
		}
		
		private function internalHandler(event:Event):void{
			switch(event.type){
				case Event.ID3:
					dispatchEvent(new LazyLoaderMediaEvent(LazyLoaderMediaEvent.METADATA_RECEIVED, id3));
					break;
				
				case IOErrorEvent.IO_ERROR:
					_status = LazyLoaderStatus.ERROR;
					dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					removeInternalHandlers();
					break;
				
				case Event.COMPLETE:
					_status = LazyLoaderStatus.COMPLETE;
					removeInternalHandlers();
					break;
			}
		}
		
		private function removeInternalHandlers():void{
			super.removeEventListener(Event.ID3, internalHandler);
			super.removeEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.removeEventListener(Event.COMPLETE, internalHandler);
		}
		
		override public function close():void{
			if(_status != LazyLoaderStatus.LOADING) return;
			_status = LazyLoaderStatus.CANCELED;
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.CANCELED, loaded, total));
			super.close();
			removeInternalHandlers();
		}
		
		public function destroy():void{
			close();
			removeInternalHandlers();
		}
		
		public function get loaded():uint { return bytesLoaded; }
		public function get total():uint { return bytesTotal; }
		public function get bytes():ByteArray{ return null; }
		public function get status():String{ return _status; }
		public function get metadata():Object{ return id3 };
	}
}