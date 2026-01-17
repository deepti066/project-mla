<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('follows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('follower_id')->constrained('users')->onDelete('cascade'); // User who follows
            $table->foreignId('following_id')->constrained('users')->onDelete('cascade'); // User being followed
            $table->timestamps();
            // A user can't follow another user twice
            $table->unique(['follower_id', 'following_id']);
            // A user can't follow themselves
            $table->check('follower_id != following_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('follows');
    }
};
