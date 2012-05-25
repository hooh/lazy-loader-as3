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