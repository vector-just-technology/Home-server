from flask import Blueprint, request, jsonify, send_from_directory
from flask_login import login_required
import os
import uuid
import traceback

wallpaper_bp = Blueprint('wallpaper', __name__)

def get_upload_dir():
    d = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'wallpapers')
    try:
        os.makedirs(d, exist_ok=True)
    except Exception:
        pass
    return d

@wallpaper_bp.route('/upload', methods=['POST'])
@login_required
def upload_wallpaper():
    if 'file' not in request.files:
        return jsonify({'error': 'No file'}), 400
    f = request.files['file']
    ext = f.filename.rsplit('.', 1)[-1].lower() if '.' in f.filename else 'png'
    if ext not in ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg']:
        return jsonify({'error': 'Invalid file type'}), 400
    name = f"{uuid.uuid4().hex}.{ext}"
    try:
        f.save(os.path.join(get_upload_dir(), name))
    except Exception as e:
        return jsonify({'error': f'Failed to save: {e}'}), 500
    return jsonify({'url': f'/api/wallpaper/file/{name}'})

@wallpaper_bp.route('/file/<name>')
def serve_wallpaper(name):
    try:
        return send_from_directory(get_upload_dir(), name)
    except Exception:
        return jsonify({'error': 'Not found'}), 404

@wallpaper_bp.route('/list')
@login_required
def list_wallpapers():
    files = []
    try:
        d = get_upload_dir()
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg')):
                    files.append({'name': f, 'url': f'/api/wallpaper/file/{f}'})
    except Exception:
        pass
    return jsonify(files)

@wallpaper_bp.route('/delete/<name>', methods=['DELETE'])
@login_required
def delete_wallpaper(name):
    try:
        path = os.path.join(get_upload_dir(), name)
        if os.path.exists(path):
            os.remove(path)
    except Exception:
        pass
    return jsonify({'message': 'Deleted'})
