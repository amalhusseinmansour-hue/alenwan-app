<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use App\Models\User;

class FilamentLoginController extends Controller
{
    /**
     * Show login form
     */
    public function showLoginForm()
    {
        // If already logged in, redirect to admin
        if (Auth::check() && Auth::user()->is_admin) {
            return redirect('/admin/movies');
        }

        return view('admin.login');
    }

    /**
     * Handle login
     */
    public function login(Request $request)
    {
        // Validate input
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $email = $request->email;
        $password = $request->password;

        // Log the attempt
        Log::info('Admin login attempt', ['email' => $email]);

        // Get user from database directly
        $user = User::where('email', $email)->first();

        // Check if user exists
        if (!$user) {
            Log::warning('User not found', ['email' => $email]);
            return redirect()
                ->back()
                ->withErrors(['email' => 'المستخدم غير موجود'])
                ->withInput($request->except('password'));
        }

        // Check if user is admin
        if (!$user->is_admin) {
            Log::warning('User is not admin', ['email' => $email, 'is_admin' => $user->is_admin]);
            return redirect()
                ->back()
                ->withErrors(['email' => 'هذا الحساب لا يملك صلاحيات الإدارة'])
                ->withInput($request->except('password'));
        }

        // Get the password hash from database
        $hashedPassword = $user->getAttributes()['password'];

        // Verify password
        $passwordCheck = Hash::check($password, $hashedPassword);

        Log::info('Password verification', [
            'email' => $email,
            'password_check' => $passwordCheck,
            'hash_starts_with' => substr($hashedPassword, 0, 10)
        ]);

        if (!$passwordCheck) {
            Log::warning('Password verification failed', ['email' => $email]);
            return redirect()
                ->back()
                ->withErrors(['email' => 'كلمة المرور غير صحيحة'])
                ->withInput($request->except('password'));
        }

        // Login the user using Auth facade
        Auth::loginUsingId($user->id, $request->boolean('remember'));
        $request->session()->regenerate();

        Log::info('User logged in successfully', [
            'user_id' => $user->id,
            'email' => $email,
            'auth_check' => Auth::check(),
            'auth_id' => Auth::id()
        ]);

        // Redirect to admin panel
        return redirect('/admin/movies');
    }

    /**
     * Handle logout
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/admin/login');
    }
}
