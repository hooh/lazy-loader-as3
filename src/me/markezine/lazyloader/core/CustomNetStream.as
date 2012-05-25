package me.markezine.lazyloader.core
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import me.markezine.lazyloader.events.LazyLoaderEvent;
	
	internal class CustomNetStream extends flash.net.NetStream{
		private var request:URLRequest;
		private var timer:Timer;
		private var prevBytesLoaded:uint;
		
		private var _uniqueId:String;
		private var _metadata:Object;
		private var _soundTransform:SoundTransform = new SoundTransform(1,0);
		private var _started:Boolean = false;
		
		public function CustomNetStream(){
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			super(nc);
			client = {onMetaData:metadataHandler};
			
			addEventListener(LazyLoaderEvent.BUFFER_FULL, bufferListener);
			super.soundTransform = new SoundTransform(0);
		}
		
		private function bufferListener(event:Event):void{
			removeEventListener(LazyLoaderEvent.BUFFER_FULL, bufferListener);
			if(!_metadata) return;
			pause();
			seek(0);
			_started = true;
			soundTransform = _soundTransform;
		}
		
		public function load(request:URLRequest):void{
			var baseURL:String = ExternalInterface.available ? ExternalInterface.call("window.location.href.toString") : "";
			if(baseURL){
				baseURL = baseURL.indexOf("#") > - 1 ? baseURL.substr(0, baseURL.indexOf("#")): baseURL;
				baseURL = baseURL.substr(0, baseURL.lastIndexOf("/")+1);
			}
			this.request = request;
			play(request.url.indexOf("://") >-1 ? request.url : baseURL + request.url);
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, timerListener);
			timer.start();
		}
		
		private function timerListener(event:TimerEvent):void{
			if(bytesLoaded != prevBytesLoaded){
				prevBytesLoaded = bytesLoaded;
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
			}
			
			if(bytesLoaded>=bytesTotal){
				timer.removeEventListener(TimerEvent.TIMER, timerListener);
				timer.stop();
				timer = null;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function metadataHandler(data:Object):void{
			_metadata = data;
			dispatchEvent(new LazyLoaderEvent(LazyLoaderEvent.METADATA_RECEIVED));
			
			if(_started) return;
			pause();
			seek(0);
			_started = true;
			soundTransform = _soundTransform;
		}
		
		public function get relativeURL():String{
			return request ? request.url: "";
		}
		
		public function get uniqueId():String{
			return _uniqueId;
		}
		
		public function set uniqueId(value:String):void{
			_uniqueId = value;
		}
		
		public function get metadata():Object{
			return _metadata;
		}
		
		override public function set soundTransform(sndTransform:SoundTransform):void{
			_soundTransform = sndTransform;
			if(_started) super.soundTransform = sndTransform;
		}
		
		override public function get soundTransform():SoundTransform{
			return _soundTransform;
		}
		
		override public function resume():void{
			super.soundTransform = _soundTransform;
			super.resume();
		}
	}
}