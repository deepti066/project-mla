<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('post_media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('post_id')->constrained()->onDelete('cascade');
            $table->enum('media_type', ['image', 'video']); // image or video
            $table->string('media_url');
            $table->string('thumbnail_url')->nullable(); // For videos
            $table->unsignedInteger('order')->default(0); // To maintain order of media
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('post_media');
    }
};
