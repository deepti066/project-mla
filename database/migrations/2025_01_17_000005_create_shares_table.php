<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('shares', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // User who shared
            $table->foreignId('post_id')->constrained()->onDelete('cascade'); // Post being shared
            $table->string('shared_to')->nullable(); // 'story', 'direct_message', etc.
            $table->timestamps();
            // Ensure a user can't share the same post twice (in the same way)
            $table->unique(['user_id', 'post_id', 'shared_to']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('shares');
    }
};
