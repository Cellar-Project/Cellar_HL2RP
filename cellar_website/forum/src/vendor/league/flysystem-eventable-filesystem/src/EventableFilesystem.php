<?php

namespace League\Flysystem\EventableFilesystem;

use League\Event\Emitter;
use League\Event\EmitterTrait;
use League\Flysystem\AdapterInterface;
use League\Flysystem\EventableFilesystem\Event\After as AfterEvent;
use League\Flysystem\EventableFilesystem\Event\Before as BeforeEvent;
use League\Flysystem\Filesystem;
use League\Flysystem\Handler;
use League\Flysystem\PluginInterface;

class EventableFilesystem extends Filesystem
{
    use EmitterTrait;

    /**
     * @var FilesystemInterface
     */
    protected $filesystem;

    /**
     * Constructor.
     *
     * @param AdapterInterface $adapter
     * @param mixed            $config
     * @param Emitter          $emitter
     */
    public function __construct(AdapterInterface $adapter, $config = null, Emitter $emitter = null)
    {
        $this->setEmitter($emitter);
        parent::__construct($adapter, $config);
    }

    /**
     * @return FilesystemInterface
     */
    public function getFilesystem()
    {
        return $this->filesystem;
    }

    /**
     * Create a file or update if exists.
     *
     * @param string $path     path to file
     * @param string $contents file contents
     * @param array  $config
     *
     * @throws FileExistsException
     *
     * @return bool success boolean
     */
    public function put($path, $contents, array $config = [])
    {
        return $this->delegateMethodCall('put', compact('path', 'contents', 'config'));
    }

    /**
     * Create a file or update if exists using a stream.
     *
     * @param string   $path
     * @param resource $resource
     * @param array    $config
     *
     * @return bool success boolean
     */
    public function putStream($path, $resource, array $config = [])
    {
        return $this->delegateMethodCall('putStream', compact('path', 'resource', 'config'));
    }

    /**
     * Read and delete a file.
     *
     * @param string $path
     * @param array  $config
     *
     * @throws FileNotFoundException
     *
     * @return string file contents
     */
    public function readAndDelete($path, array $config = [])
    {
        return $this->delegateMethodCall('readAndDelete', compact('path', 'config'));
    }

    /**
     * Get a file/directory handler.
     *
     * @param string  $path
     * @param Handler $handler
     * @param mixed   $config
     *
     * @return Handler file or directory handler
     */
    public function get($path, Handler $handler = null, array $config = [])
    {
        return $this->delegateMethodCall('get', compact('path', 'handler', 'config'));
    }

    /**
     * Register a plugin.
     *
     * @param PluginInterface $plugin
     * @param mixed           $config
     *
     * @return $this
     */
    public function addPlugin(PluginInterface $plugin, array $config = [])
    {
        $this->delegateMethodCall('addPlugin', compact('plugin', 'config'));

        return $this;
    }

    /**
     * Check whether a file exists.
     *
     * @param string $path
     * @param array  $config
     *
     * @return bool
     */
    public function has($path, array $config = [])
    {
        return $this->delegateMethodCall('has', compact('path', 'config'));
    }

    /**
     * Read a file.
     *
     * @param string $path
     * @param array  $config
     *
     * @return false|array
     */
    public function read($path, array $config = [])
    {
        return $this->delegateMethodCall('read', compact('path', 'config'));
    }

    /**
     * Read a file as a stream.
     *
     * @param string $path
     * @param array  $config
     *
     * @return false|array
     */
    public function readStream($path, $config = [])
    {
        return $this->delegateMethodCall('readStream', compact('path', 'config'));
    }

    /**
     * List contents of a directory.
     *
     * @param string $directory
     * @param bool   $recursive
     * @param array  $config
     *
     * @return false|array
     */
    public function listContents($directory = '', $recursive = false, array $config = [])
    {
        return $this->delegateMethodCall('listContents', compact('directory', 'recursive', 'config'));
    }

    /**
     * Get all the meta data of a file or directory.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return false|array
     */
    public function getMetadata($path, array $config = [])
    {
        return $this->delegateMethodCall('getMetadata', compact('path', 'config'));
    }

    /**
     * Get all the meta data of a file or directory.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return false|array
     */
    public function getSize($path, array $config = [])
    {
        return $this->delegateMethodCall('getSize', compact('path', 'config'));
    }

    /**
     * Get the mimetype of a file.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return false|array
     */
    public function getMimetype($path, array $config = [])
    {
        return $this->delegateMethodCall('getMimetype', compact('path', 'config'));
    }

    /**
     * Get the timestamp of a file.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return false|array
     */
    public function getTimestamp($path, array $config = [])
    {
        return $this->delegateMethodCall('getTimestamp', compact('path', 'config'));
    }

    /**
     * Get the visibility of a file.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return false|array
     */
    public function getVisibility($path, array $config = [])
    {
        return $this->delegateMethodCall('getVisibility', compact('path', 'config'));
    }

    /**
     * Write a new file.
     *
     * @param string $path
     * @param string $contents
     * @param mixed  $config   Config object or visibility setting
     *
     * @return false|array false on failure file meta data on success
     */
    public function write($path, $contents, array $config = [])
    {
        return $this->delegateMethodCall('write', compact('path', 'contents', 'config'));
    }

    /**
     * Update a file.
     *
     * @param string $path
     * @param string $contents
     * @param mixed  $config   Config object or visibility setting
     *
     * @return false|array false on failure file meta data on success
     */
    public function update($path, $contents, array $config = [])
    {
        return $this->delegateMethodCall('update', compact('path', 'contents', 'config'));
    }

    /**
     * Write a new file using a stream.
     *
     * @param string   $path
     * @param resource $resource
     * @param mixed    $config   Config object or visibility setting
     *
     * @return false|array false on failure file meta data on success
     */
    public function writeStream($path, $resource, array $config = [])
    {
        return $this->delegateMethodCall('writeStream', compact('path', 'resource', 'config'));
    }

    /**
     * Update a file using a stream.
     *
     * @param string   $path
     * @param resource $resource
     * @param mixed    $config   Config object or visibility setting
     *
     * @return false|array false on failure file meta data on success
     */
    public function updateStream($path, $resource, array $config = [])
    {
        return $this->delegateMethodCall('updateStream', compact('path', 'resource', 'config'));
    }

    /**
     * Rename a file.
     *
     * @param string $path
     * @param string $newpath
     * @param mixed  $config
     *
     * @return bool
     */
    public function rename($path, $newpath, array $config = [])
    {
        return $this->delegateMethodCall('rename', compact('path', 'newpath', 'config'));
    }

    /**
     * Copy a file.
     *
     * @param string $path
     * @param string $newpath
     * @param mixed  $config
     *
     * @return bool
     */
    public function copy($path, $newpath, array $config = [])
    {
        return $this->delegateMethodCall('copy', compact('path', 'newpath', 'config'));
    }

    /**
     * Delete a file.
     *
     * @param string $path
     * @param mixed  $config
     *
     * @return bool
     */
    public function delete($path, array $config = [])
    {
        return $this->delegateMethodCall('delete', compact('path', 'config'));
    }

    /**
     * Delete a directory.
     *
     * @param string $dirname
     * @param mixed  $config
     *
     * @return bool
     */
    public function deleteDir($dirname, array $config = [])
    {
        return $this->delegateMethodCall('deleteDir', compact('dirname', 'config'));
    }

    /**
     * Create a directory.
     *
     * @param string $dirname directory name
     * @param mixed  $config
     *
     * @return bool
     */
    public function createDir($dirname, array $config = [])
    {
        return $this->delegateMethodCall('createDir', compact('dirname', 'config'));
    }

    /**
     * Set the visibility for a file.
     *
     * @param string $path
     * @param string $visibility
     * @param mixed  $config
     *
     * @return file meta data
     */
    public function setVisibility($path, $visibility, array $config = [])
    {
        return $this->delegateMethodCall('setVisibility', compact('path', 'visibility', 'config'));
    }

    /**
     * Do all the work to call the method and emit the events.
     *
     * @param string $method
     * @param array  $arguments
     *
     * @return mixed
     */
    public function delegateMethodCall($method, array $arguments = [])
    {
        $config = $arguments['config'];

        if (isset($config['silent']) && $config['silent'] === true) {
            return $this->callFilesystemMethod($method, $arguments);
        }

        list($continue, $result) = $this->emitBefore($method, $arguments);

        if (! $continue) {
            return $result;
        }

        $result = $this->callFilesystemMethod($method, $result);

        return $this->emitAfter($method, $result, $arguments);
    }

    /**
     * Emit the before event.
     *
     * @param string $method
     * @param array  $arguments
     *
     * @return array [continue, call result]
     */
    protected function emitBefore($method, array $arguments)
    {
        $event = new BeforeEvent($this, $method, $arguments);
        $this->emit($event, $method);

        if ($event->isPropagationStopped()) {
            return [false, $event->getResult()];
        }

        return [true, $event->getArguments()];
    }

    /**
     * Call the underlying filesystem method.
     *
     * @param string $method
     * @param array  $arguments
     *
     * @return mixed
     */
    protected function callFilesystemMethod($method, array $arguments)
    {
        $callable = 'parent::'.$method;
        $result = call_user_func_array($callable, array_values($arguments));

        return $result;
    }

    /**
     * Emit the after event.
     *
     * @param string $method
     * @param mixed  $result
     * @param array  $arguments
     *
     * @return mixed
     */
    protected function emitAfter($method, $result, array $arguments)
    {
        $event = new AfterEvent($this, $method, $result, $arguments);
        $this->emit($event);

        return $event->getResult();
    }
}
