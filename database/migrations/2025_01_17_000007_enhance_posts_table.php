<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('posts', function (Blueprint $table) {
            // These columns will be deprecated but kept for backward compatibility
            if (Schema::hasColumn('posts', 'media_type')) {
                $table->string('media_type')->nullable()->change();
            }
            if (Schema::hasColumn('posts', 'media_url')) {
                $table->string('media_url')->nullable()->change();
            }
            
            // Add new columns for enhanced functionality
            if (!Schema::hasColumn('posts', 'caption')) {
                $table->text('caption')->nullable();
            }
            if (!Schema::hasColumn('posts', 'is_archived')) {
                $table->boolean('is_archived')->default(false)->after('content');
            }
            if (!Schema::hasColumn('posts', 'deleted_at')) {
                $table->softDeletes()->after('is_archived');
            }
            if (!Schema::hasColumn('posts', 'published_at')) {
                $table->timestamp('published_at')->nullable()->after('deleted_at');
            }
        });
    }

    public function down()
{
    Schema::table('posts', function (Blueprint $table) {

        if (Schema::hasColumn('posts', 'is_archived')) {
            $table->dropColumn('is_archived');
        }

        if (Schema::hasColumn('posts', 'published_at')) {
            $table->dropColumn('published_at');
        }

        if (Schema::hasColumn('posts', 'deleted_at')) {
            $table->dropSoftDeletes();
        }

        // caption rollback (optional — decide intentionally)
        if (Schema::hasColumn('posts', 'caption')) {
            $table->dropColumn('caption');
        }
    });
}
};
