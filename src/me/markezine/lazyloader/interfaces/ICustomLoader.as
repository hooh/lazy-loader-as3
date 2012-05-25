package me.markezine.lazyloader.interfaces
{
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public interface ICustomLoader extends IEventDispatcher
	{
		function lazyLoad(request:URLRequest, context:Object=null):void;
		function close():void;
		function destroy():void;
		function get status():String;
		function get loaded():uint;
		function get total():uint;
		function get bytes():ByteArray;
		function get metadata():Object;
	}
}