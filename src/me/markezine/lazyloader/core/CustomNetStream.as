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
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import me.markezine.lazyloader.events.LazyLoaderErrorEvent;
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	import me.markezine.lazyloader.events.LazyLoaderMediaEvent;
	import me.markezine.lazyloader.interfaces.ICustomLoader;
	
	internal class CustomNetStream extends flash.net.NetStream implements ICustomLoader{
		private var request:URLRequest;
		private var timer:Timer;
		
		private var _metadata:Object;
		private var _soundTransform:SoundTransform = new SoundTransform(1,0);
		private var _bufferOk:Boolean = false;
		private var _prevBytesLoaded:uint;
		private var _startPlaying:Boolean = false;
		private var _status:String = LazyLoaderStatus.WAITING;
		
		public function CustomNetStream(){
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			super(nc);
			super.soundTransform = new SoundTransform(0);
		}
		
		public function lazyLoad(request:URLRequest, context:Object = null):void{
			if(_status!=LazyLoaderStatus.WAITING && status != LazyLoaderStatus.CANCELED && status!=LazyLoaderStatus.ERROR) return;
			dispatchEvent(new Event(Event.OPEN));
			_status = LazyLoaderStatus.LOADING;
			super.play(request.url);
			client = {onMetaData:metadataHandler, onImageData:imageDataHandler};
			addInternalHandlers();
			initialPause();
		}
		
		override public function play(...parameters):void{
		}
		
		override public function play2(param:NetStreamPlayOptions):void{
		}
		
		private function addInternalHandlers():void{
			super.addEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.addEventListener(NetStatusEvent.NET_STATUS, internalHandler);
			super.addEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler);
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, internalHandler);
			timer.start();
		}
		
		private function metadataHandler(data:Object):void{
			if(_metadata) return;
			_metadata = data;
			dispatchEvent(new LazyLoaderMediaEvent(LazyLoaderMediaEvent.METADATA_RECEIVED, _metadata));
		}
		
		private function imageDataHandler(data:Object):void{
			//TO-DO: implement imagedata event dispatching
		}
		
		private function initialPause():void{
			pause();
			seek(0);
			if(_startPlaying) resume();
			soundTransform = _soundTransform;
		}
		
		private function internalHandler(event:Event):void{
			switch(event.type){
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					_status = LazyLoaderStatus.ERROR;
					dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
					removeInternalHandlers();
					break;
				
				case NetStatusEvent.NET_STATUS:
					if(NetStatusEvent(event).info.code == "NetStream.Buffer.Full" && !_bufferOk){
						_bufferOk = true;
						initialPause();
						dispatchEvent(new LazyLoaderMediaEvent(LazyLoaderMediaEvent.BUFFER_FULL, null));
						return;
					}
					
					if(NetStatusEvent(event).info.code == "NetStream.Seek.InvalidTime"){
						seek(NetStatusEvent(event).info.details);
						return;
					}
					
					if(NetStatusEvent(event).info.level == "error"){
						_status = LazyLoaderStatus.ERROR;
						dispatchEvent(new LazyLoaderErrorEvent(LazyLoaderErrorEvent.LAZYLOADER_ERROR, event));
						removeInternalHandlers();
					}
					break;
				
				case TimerEvent.TIMER:
					if(bytesLoaded != _prevBytesLoaded){
						_prevBytesLoaded = bytesLoaded;
						dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.PROGRESS, bytesLoaded, bytesTotal));
					}
					
					if(bytesLoaded>=bytesTotal){
						_status = LazyLoaderStatus.COMPLETE;
						dispatchEvent(new Event(Event.COMPLETE));
						removeInternalHandlers();
					}
					break;
			}
		}
		
		private function removeInternalHandlers():void{
			super.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, internalHandler);
			super.removeEventListener(IOErrorEvent.IO_ERROR, internalHandler);
			super.removeEventListener(NetStatusEvent.NET_STATUS, internalHandler);
			super.removeEventListener(Event.COMPLETE, internalHandler);
			super.removeEventListener(LazyLoaderMediaEvent.BUFFER_FULL, internalHandler);
			if(!timer) return;
			timer.removeEventListener(TimerEvent.TIMER, internalHandler);
			timer.stop();
			timer = null;
		}
		
		override public function close():void{
			if(_status != LazyLoaderStatus.LOADING) return;
			_status = LazyLoaderStatus.CANCELED;
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.CANCELED, loaded, total));
			removeInternalHandlers();
			super.close();
		}
		
		override public function resume():void{
			super.soundTransform = _soundTransform;
			super.resume();
			_bufferOk = true;
			_startPlaying = true;
		}
		
		override public function set soundTransform(sndTransform:SoundTransform):void{
			_soundTransform = sndTransform;
			if(_bufferOk) super.soundTransform = sndTransform;
		}
		
		public function destroy():void{
			close();
			removeInternalHandlers();
		}
		
		override public function get soundTransform():SoundTransform{ return _soundTransform; }
		public function get metadata():Object{ return _metadata; }
		public function get bytes():ByteArray{ return null; }
		public function get loaded():uint{ return bytesLoaded; }
		public function get total():uint{ return bytesTotal; }
		public function get status():String{ return _status; }

	}
}