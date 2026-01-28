<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        Schema::create('follows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('follower_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('following_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['follower_id', 'following_id']);
        });

        // Add check constraint manually using raw SQL
        DB::statement('ALTER TABLE follows ADD CONSTRAINT check_follower_not_self CHECK (follower_id <> following_id)');
    }

    public function down()
    {
        Schema::dropIfExists('follows');
    }
};
