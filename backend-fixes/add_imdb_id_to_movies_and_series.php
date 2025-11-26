<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // إضافة حقل imdb_id إلى جدول movies
        Schema::table('movies', function (Blueprint $table) {
            $table->string('imdb_id')->nullable()->unique()->after('id');
            $table->index('imdb_id');
        });

        // إضافة حقل imdb_id إلى جدول series
        Schema::table('series', function (Blueprint $table) {
            $table->string('imdb_id')->nullable()->unique()->after('id');
            $table->index('imdb_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('movies', function (Blueprint $table) {
            $table->dropIndex(['imdb_id']);
            $table->dropColumn('imdb_id');
        });

        Schema::table('series', function (Blueprint $table) {
            $table->dropIndex(['imdb_id']);
            $table->dropColumn('imdb_id');
        });
    }
};
