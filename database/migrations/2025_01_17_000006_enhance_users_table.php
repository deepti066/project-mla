<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            // Add new columns if they don't exist
            if (!Schema::hasColumn('users', 'bio')) {
                $table->text('bio')->nullable()->after('email');
            }
            if (!Schema::hasColumn('users', 'avatar_url')) {
                $table->string('avatar_url')->nullable()->after('bio');
            }
            if (!Schema::hasColumn('users', 'is_verified')) {
                $table->boolean('is_verified')->default(false)->after('avatar_url');
            }
            if (!Schema::hasColumn('users', 'fcm_token')) {
                $table->string('fcm_token')->nullable()->after('is_verified');
            }
            if (!Schema::hasColumn('users', 'last_seen_at')) {
                $table->timestamp('last_seen_at')->nullable()->after('fcm_token');
            }
            if (!Schema::hasColumn('users', 'is_private')) {
                $table->boolean('is_private')->default(false)->after('last_seen_at');
            }
            if (!Schema::hasColumn('users', 'soft_deleted_at')) {
                $table->softDeletes()->after('is_private');
            }
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumnIfExists(['bio', 'avatar_url', 'is_verified', 'fcm_token', 'last_seen_at', 'is_private', 'deleted_at']);
        });
    }
};
